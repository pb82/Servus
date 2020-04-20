defmodule Servus.Supervisor do
  @moduledoc """
  Servus entry point. Reads the configuration file and starts all configured
  game backends accordingly.
  """

  @backends Application.get_env(:servus, :backends)
  @modules Application.get_env(:servus, :modules)

  def start_link do
    import Supervisor.Spec
    alias Servus.PlayerQueue

    # Common services used by all backends
    children = [
      worker(Servus.PidStore, []),
      worker(Servus.ModuleStore, []),
      supervisor(Task.Supervisor, [[name: :client_handler]], id: :client_handler),
      supervisor(Task.Supervisor, [[name: :game_handler]], id: :game_handler)
    ]

    # Create a list of all the backends that have to be
    # started
    backends =
      Enum.map(@backends, fn backend ->
        backend = Application.get_env(:servus, backend)
        players = backend[:players_per_game]
        logic = backend[:implementation]
        adapters = backend[:adapters]

        # Already create the player queue for the backend
        queue_pid = PlayerQueue.start_link(players, logic)

        supervisor(Servus.Backend.Supervisor, [adapters, queue_pid], id: backend)
      end)

    # Create a list of all the modules that have to be
    # started
    modules =
      Enum.map(@modules, fn module ->
        worker(module, [[name: module]])
      end)

    # Start the common services and all backends
    Supervisor.start_link(children ++ backends ++ modules, strategy: :one_for_one)
  end
end
