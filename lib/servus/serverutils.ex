defmodule Servus.Serverutils.TCP do
  @moduledoc """
  Implementation of send/3 and recv/2 for TCP sockets
  """

  @doc """
  Returns IP address associated with a socket (usually the
  client socket)
  """
  def get_address(socket) do
    {:ok, {address, _}} = :inet.peername(socket)
    address |> Tuple.to_list |> Enum.join "."
  end

  @doc """
  Sends a message via TCP socket. The message will always have
  the form `{"type": type,"value": value}`
  """
  def send(socket, type, value) do
    {:ok, json} = Poison.encode %{
      type: type,
      value: value
    }

    :gen_tcp.send socket, json
  end

  @doc """
  Wait for a message on a TCP socket. A timeout can be passed
  in the `opts`. The default timeout should be `:infinity`. If
  `opts[:parse]` is true then a data will be parsed as JSON and
  returned as a `Servus.Message` struct. Otherwise the data will
  be returned as string.
  """
  def recv(socket, opts) do
    result = :gen_tcp.recv(socket, 0, opts[:timeout])
    case result do
      {:ok, data} ->
        if opts[:parse] do
          {:ok, msg} = Poison.decode data, as: Servus.Message
          msg
        else
          result
        end
      _ ->
        result
    end
  end
end

defmodule Servus.Serverutils.Web do
  @moduledoc """
  Implementation of send/3 and recv/1 for WebSocket connections
  """

  @doc """
  Returns IP address associated with a socket (usually the
  client socket)
  """
  def get_address(socket) do
    Serverutils.TCP.get_address(socket)
  end

  @doc """
  Sends a message via WebSocket. The message will always have
  the form `{"type": type,"value": value}`
  """
  def send(socket, type, value) do
    {:ok, json} = Poison.encode %{
      type: type,
      value: value
    }

    Socket.Web.send! socket, {:text, json}
  end

  @doc """
  Wait for a message on a WebSocket connection. Other than TCP sockets
  this does not have any options at the moment. Messages will be
  returned raw.
  """
  def recv(socket) do
    result = Socket.Web.recv! socket
    case result do
      {:text, data} ->
        {:ok, data}
      {:close, reason, _} ->
        {:error, reason}
      _ ->
        {:error, :unknown}
    end
  end
end

defmodule Servus.Serverutils do
  @moduledoc """
  A facade to hide all actual socket interactions and provide the
  same API for TCP and WebSockets (and more to come? UDP?)

  Also contains some utility functions (`get_unique_id/0`)
  """

  alias Servus.Serverutils.Web
  alias Servus.Serverutils.TCP

  # IDs
  # ###############################################
  defp now do
    :os.timestamp
    |> Tuple.to_list
    |> Enum.reduce 0, fn (x, acc) -> x + acc end
  end

  def get_unique_id do
    :crypto.rand_uniform(1, 100) * now
  end
  # ###############################################


  # Addresses
  # ###############################################
  def get_address(%Socket.Web{socket: socket}) do
    Web.get_address(socket)
  end

  def get_address(socket) do
    TCP.get_address(socket)
  end
  # ###############################################


  # WebSocket
  # ###############################################
  def send(%{raw: socket, type: :web}, type, value) do
    Web.send(socket, type, value)
  end

  def recv(%{raw: socket, type: :web}) do
    Web.recv(socket)
  end
  
  
  # ###############################################
  # TCP Socket
  # ###############################################
  def send(%{raw: socket, type: :tcp}, type, value) do
    TCP.send(socket, type, value)
  end

  def recv(%{raw: socket, type: :tcp}, opts \\ [parse: false, timeout: :infinity]) do
    TCP.recv(socket, opts)
  end
  # ###############################################

  
  # Module call
  # ###############################################
  def call(target, type, value) do
    pid = ModuleStore.get(target)
    
    if pid != nil and Process.alive?(pid) do
      GenServer.call(pid, {:priv, type, value})
    else
      :error
    end
  end
  # ###############################################
end
