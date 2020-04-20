defmodule SocketServer do
  @moduledoc """
  Manages the connections on a socket for a single game
  backend. Each game backend has it's own SocketServer
  """

  require Logger
  alias Servus.Serverutils
  alias Servus.ClientHandler

  def start_link(port, queue_pid) do
    {:ok, socket} =
      :gen_tcp.listen(port, [
        :binary,
        packet: 4,
        active: false,
        reuseaddr: true
      ])

    Logger.info("Accepting tcp connections on port #{port}")

    {:ok, spawn_link(fn -> accept(socket, queue_pid) end)}
  end

  def accept(socket, queue_pid) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("Incomming TCP connection from #{Serverutils.get_address(client)}")

    # Start a new client listener thread for the incoming connection
    Task.Supervisor.start_child(:client_handler, ClientHandler, :run, [
      %{socket: %{raw: client, type: :tcp}, queue: queue_pid}
    ])

    # Wait for the next connection
    accept(socket, queue_pid)
  end
end
