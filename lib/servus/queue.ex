defmodule Servus.PlayerQueue do
  use GenServer
  require Logger
  alias Servus.PidStore

  def init(init_arg) do
    {:ok, init_arg}
  end

  @doc """
  Start a new player queue for a backend of type `logic`
  allowing `players_per_game` players.
  """
  def start_link(players_per_game, logic) do
    {:ok, pid} =
      GenServer.start_link(__MODULE__, %{
        queue: [],
        size: players_per_game,
        logic: logic
      })

    pid
  end

  def handle_call({:push, player}, _, state) do
    state = %{state | :queue => [player | state.queue]}

    cond do
      state.size == length(state.queue) ->
        pid = state.logic.start(state.queue)

        Enum.each(state.queue, fn player ->
          PidStore.put(player.id, pid)
        end)

        Logger.info("Started a new #{state.logic} with #{state.size} players")

        {:reply, :ok, %{state | :queue => []}}

      true ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:remove, player}, _, state) do
    queue =
      Enum.reduce(state.queue, [], fn candidate, acc ->
        if candidate.id == player.id do
          acc
        else
          [candidate | acc]
        end
      end)

    state = %{state | :queue => queue}

    {:reply, :ok, state}
  end

  @doc """
  Add a new player to the queue. This is a synchronous call and will
  return when the player was succesfully added.
  """
  def push(pid, player) do
    GenServer.call(pid, {:push, player})
  end

  @doc """
  Remove a player from the queue (by it's pid). This function is called when
  a player that is still in the queue (and thus not in a game) aborts the
  connection. If we would not remove him at this point he would count as a
  valid opponent.
  """
  def remove(pid, player) do
    GenServer.call(pid, {:remove, player})
  end
end
