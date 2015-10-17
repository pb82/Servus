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
