defmodule Serverutils do
  @on_load :seed

  defp now do
    :erlang.now 
    |> Tuple.to_list 
    |> Enum.reduce 0, fn (x, acc) -> x + acc end
  end

  def seed do
    :crypto.rand_seed <<now>>
    :ok
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

    :gen_tcp.send socket, json <> "\r\n"
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
