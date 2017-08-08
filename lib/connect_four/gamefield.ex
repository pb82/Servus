defmodule Gamefield do
  use GenServer

  # Interface

  @doc """
  Entry point. No use for a name since there are always multiple
  instances running
  """
  def start_link do
    GenServer.start_link(__MODULE__, produce_empty_field())
  end

  @doc """
  Reset the game field to empty state
  """
  def reset_game(server) do
    GenServer.cast(server, :resetGame)
  end

  @doc """
  Put a coin of `playerID` into `slot`
  """
  def update_field(server,slot,playerID) do
    GenServer.call(server, {:updateField,slot, playerID})
  end

  @doc """
  Check wether the field contains a winner. This call will only
  return `true` or `false` and not the winning player. By the rules
  of this game only the last active player can be the winner.
  """
  def check_win_condition(server) do
    GenServer.call(server, :checkWinCondition)
  end

  # Produce an empty game field. A game field is a nested array of
  # eight arrays. Each of the nested arrays contains eight times the
  # value `nil` (empty state).
  defp produce_empty_field do
    for _ <- 0..7, do: (for _ <- 0..7, do: nil)
  end

  # Implementation

  def handle_cast(:resetGame, _) do
    {:noreply, produce_empty_field}
  end

  def handle_call({:updateField, slot,playerID}, _, gamefield)do
    column = Enum.at(gamefield, slot)
    newColumn = put_coin(column, playerID, 0)
    newGameField = Listhelp.put_item(gamefield, slot, newColumn)
    {:reply, :ok, newGameField}
  end

  def handle_call(:checkWinCondition,_,gamefield) do
    values = [
      gamefield,
      Fieldchecker.rotate(gamefield),
      Fieldchecker.arrow_right(gamefield),
      Fieldchecker.arrow_left(gamefield)
    ]

    status = Enum.reduce values, false, fn (x, acc) ->
      acc or check_field(x)
    end

    {:reply, status, gamefield}
  end

  
  # Check the game field. If one of the columns contains
  # a winning condition (four coins of the same type in 
  # a row) then return true.
  defp check_field(field) do
    values = Enum.map(field, fn(column) ->
      case Fieldchecker.count(column) do
        {_, 4} ->
          true
        _ ->
          false
      end
    end)

    Enum.reduce(values, false, fn (x, acc) -> x or acc end)
  end

  # Put a coin of `player` in `column`
  defp put_coin(column, _, level) when level > 7, do: column
  defp put_coin(column, player, level) do
    if Enum.at(column, level) == nil do
      Listhelp.put_item(column, level, player)
    else
      put_coin(column, player, level + 1)
    end
  end
end
