defmodule Servus.Backend.Supervisor do
  @moduledoc """
  Entry point for a single game backend. This is used by the main
  supervisor to start the backends.
  """

  def start_link(port, players, logic, type) do
    import Supervisor.Spec

    # At the moment TCP  and WebSocket servers are supported
    # Stop with runtime error if unknown
    server = cond do
      type == :tcp  -> SocketServer
      type == :web  -> WebSocketServer
      true          -> raise "Unkown socket type #{type}"
    end

    children = [
      worker(server, [port, players, logic])
    ] 

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
