defmodule PlayerQueue do
  use GenServer
	require Logger

  @doc """
  Start a new player queue for a backend of type `logic`
  allowing `players_per_game` players.
  """
  def start_link(players_per_game, logic) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{
      queue: [], 
      size: players_per_game,
      logic: logic
    })

    pid
  end

  @doc """
  Add a new player to the queue. This is a synchronous call and will
  return when the player was succesfully added.
  """
  def push(pid, player) do
    GenServer.call(pid, {:push, player})
  end

  def handle_call({:push, player}, _, state) do
    state = %{state | :queue => [player | state.queue]}

    cond do
      state.size == length(state.queue) ->
        pid = state.logic.start state.queue
        
        Enum.each(state.queue, fn player ->
          PidStore.put(player.id, pid)
        end)

        Logger.debug "Started a new #{state.logic} with #{state.size} players"
        
        {:reply, :ok, %{state | :queue => []}}
      true ->
        {:reply, :ok, state}
    end
  end
end
