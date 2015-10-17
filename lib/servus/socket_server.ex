defmodule SocketServer do
  @moduledoc """
  Manages the connections on a socket for a single game
  backend. Each game backend has it's own SocketServer
  """
require Logger
alias Servus.PlayerQueue

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
