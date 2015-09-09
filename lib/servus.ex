defmodule Servus do
  @moduledoc"""
  The `Servus` Game Server
  A simple, modular and universal game backend
  """
  
  use Application
  require Logger

  defmodule ClientHandler do
    @moduledoc """
    Handles the socket connection of a client (player). All messages are
    received via tcp and interpreted as JSON.
    """
    
    def run(state) do
      case :gen_tcp.recv(state.socket, 0) do
        {:ok, message} ->
          data = Poison.decode message, as: Servus.Message
          
          case data do
            {:ok, %{type: type, target: target, value: value}} ->
              # Call external module
              pid = ModuleStore.get(target)

              # Check if the module is registered and available
              # and if yes...
              if pid != nil and Process.alive?(pid) do
                # ...invoke a synchronous call and send the result back
                # to the calles (client socket)
                result = GenServer.call(pid, {type, value})
                Serverutils.send(state.socket, target, result)
              end

              run(state)
            {:ok, %{type: "join", value: name}} ->
              # The special `join` message
              
              # Double join?
              if Map.has_key?(state, :player) do
                Logger.error "A player already joined on this connection"
                run(state)
              else
                Logger.debug "#{name} has joined the queue"
              
                # Create a new player and add it to the queue
                player = %{
                  name: name, 
                  socket: state.socket, 
                  id: Serverutils.get_unique_id
                }

                PlayerQueue.push(state.queue, player)

                # Store the player in the process state
                run(Map.put(state, :player, player))
              end
            {:ok, %{type: type, value: value}} ->
              # Generic message from client (player)
              
              # Check if the game state machine has already been started
              # by querying it's pid from the PidStore. This is only
              # required if it's not already stored in the process state
              if not Map.has_key?(state, :fsm) do
                pid = PidStore.get(state.player.id)
                if pid != nil do
                  state = Map.put(state, :fsm, pid)
                end
              end

              # Try to get the pid of the game state machine and send
              # the command
              pid = state.fsm
              if pid != nil do
                :gen_fsm.send_event(pid, {state.player.id, type, value})
              end

              run(state)
            _ ->
              Logger.error "Invalid message format: #{message}"
              run(state)
          end
        {:error, _} ->
          # Client has aborted the connection
          # De-register it's ID from the pid store
          if Map.has_key?(state, :player) do
            pid = PidStore.get(state.player.id)
            if pid != nil do
              # Notify the game logic about the player disconnect
              :gen_fsm.send_all_state_event(pid, {:abort, state.player})
              
              # Remove the player from the registry
              PidStore.remove(state.player.id)

              Logger.debug "Removed player from pid store"
            end
          end
        
          Logger.error "Unexpected clientside abort"
      end
    end
  end
  
  defmodule SocketServer do
    @moduledoc """
    Manages the connections on a socket for a single game
    backend. Each game backend has it's own SocketServer
    """

    def start_link(port, players, logic) do
      {:ok, socket} = :gen_tcp.listen(port, [
        :binary, 
        packet: :line, 
        active: false,
        reuseaddr: true
      ])
      
      # Start the player queue (one per socket server)
      queue_pid = PlayerQueue.start_link players, logic

      Logger.debug "Accepting connections for #{logic} on port #{port}"
      
      {:ok, spawn_link fn -> accept(socket, queue_pid) end}
    end

    def accept(socket, queue_pid) do
      {:ok, client} = :gen_tcp.accept(socket)
      Logger.debug "Incomming connection from #{Serverutils.get_address(client)}"
      
      # Start a new client listener thread for the incoming connection
      Task.Supervisor.start_child(:client_handler, ClientHandler, :run, [
        %{socket: client, queue: queue_pid}
      ])
      
      # Wait for the next connection
      accept(socket, queue_pid)
    end
  end

  defmodule Servus.Backend.Supervisor do
    @moduledoc """
    Entry point for a single game backend. This is used by the main
    supervisor to start the backends.
    """

    def start_link(port, players, logic) do
      import Supervisor.Spec

      children = [
        worker(SocketServer, [port, players, logic])
      ] 

      Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
  
  defmodule Servus.Supervisor do
    @moduledoc """
    Servus entry point. Reads the configuration file and starts all configured
    game backends accordingly.
    """
    
    @backends Application.get_env(:base, :backends)
    @modules  Application.get_env(:base, :modules)

    def start_link do
      import Supervisor.Spec

      # Common services used by all backends
      children = [
        worker(PidStore, []),
        worker(ModuleStore, []),
        supervisor(Task.Supervisor, [[name: :client_handler]], id: :client_handler),
        supervisor(Task.Supervisor, [[name: :game_handler]], id: :game_handler)
      ]

      # Create a list of all the backends that have to be
      # started
      backends = Enum.map(@backends, fn backend ->
        port     = Application.get_env(backend, :port)
        players  = Application.get_env(backend, :players_per_game)
        logic    = Application.get_env(backend, :implementation)
        
        supervisor(Servus.Backend.Supervisor, [port, players, logic], id: backend)
      end)

      # Create a list of all the modules that have to be
      # started
      modules = Enum.map(@modules, fn module ->
        worker(module, [[name: module]])
      end)

      # Start the common services and all backends
      Supervisor.start_link(children ++ backends ++ modules, strategy: :one_for_one)
    end
  end

  # Entry point
  def start(_type, _args) do
    Servus.Supervisor.start_link
  end
end
