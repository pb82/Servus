defmodule WebSocketServer do
  @moduledoc """
  Same as socket_server but fur web- instead of tcp sockets.
  """

  require Logger
  alias Servus.ClientHandler
  alias Servus.Serverutils

  def start_link(port, queue_pid) do
    socket = Socket.Web.listen!(port)

    Logger.info("Accepting websocket connections on port #{port}")

    {:ok, spawn_link(fn -> accept(socket, queue_pid) end)}
  end

  def accept(socket, queue_pid) do
    client = Socket.Web.accept!(socket)
    Socket.Web.accept!(client)

    Logger.info("Incomming WebSocket connection from #{Serverutils.get_address(client)}")

    # Start a new client listener thread for the incoming connection
    Task.Supervisor.start_child(:client_handler, ClientHandler, :run, [
      %{socket: %{raw: client, type: :web}, queue: queue_pid}
    ])

    # Wait for the next connection
    accept(socket, queue_pid)
  end
end
