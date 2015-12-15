defmodule Servus.Serverutils do
  defp now do
    :os.timestamp
    |> Tuple.to_list
    |> Enum.reduce 0, fn (x, acc) -> x + acc end
  end

  def get_unique_id do
    :crypto.rand_uniform(1, 100) * now
  end

  def get_address(socket) do
    {:ok, {address, _}} = :inet.peername(socket)
    address |> Tuple.to_list |> Enum.join "."
  end

  def send(socket, type, value) do
    {:ok, json} = Poison.encode %{
      type: type,
      value: value
    }

    :gen_tcp.send socket, json
  end

  def recv(socket, opts \\ [parse: false, timeout: :infinity]) do
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

  def call(target, type, value) do
    pid = ModuleStore.get(target)
    
    if pid != nil and Process.alive?(pid) do
      GenServer.call(pid, {:priv, type, value})
    else
      :error
    end
  end
end
