defmodule Servus.Backend.Supervisor do
  @moduledoc """
  Entry point for a single game backend. This is used by the main
  supervisor to start the backends.
  """

  def adapter_for(:tcp), do: SocketServer
  def adapter_for(:web), do: WebSocketServer

  def start_link(adapters, queue_pid) do
    import Supervisor.Spec

    children =
      Enum.map(adapters, fn {type, port} ->
        worker(adapter_for(type), [port, queue_pid])
      end)

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
