defmodule ConnectFour do
  use Servus.Game
  require Logger

  alias Servus.Serverutils

  def init(players) do
    Logger.debug "Initializing game state machine"

    [player2, player1] = players
    {:ok, field_pid} = Gamefield.start_link

    fsm_state = %{player1: player1, player2: player2, field: field_pid}

    Serverutils.send(player1.socket, "start", player2.name)
    Serverutils.send(player2.socket, "start", player1.name)
    Serverutils.send(player2.socket, "turn", nil)

    {:ok, :p2, fsm_state}
  end

  @doc """
  When one of the players looses the connection this callback will
  be invoked. Send the remaining player a message and let the client
  decide what to do.
  """
  def abort(player, state) do
    Logger.warn "Player #{player.name} has aborted the game"
    cond do
      player.id == state.player1.id ->
        Serverutils.send(state.player2.socket, "abort", state.player1.id)
        {:stop, :shutdown, state}
      player.id == state.player2.id ->
        Serverutils.send(state.player1.socket, "abort", state.player2.id)
        {:stop, :shutdown, state}
    end
  end

  @doc """
  FSM is in state `p2`. Player 2 puts.
  Outcome: p1 state
  """
  def p2({id, "put", slot}, state) do
    cond do
      id != state.player2.id ->
        Logger.warn "Not your turn"
        {:next_state, :p2, state}
      slot in 0..7 ->
        Gamefield.update_field(state.field, slot, :p2)
        if Gamefield.check_win_condition(state.field) do  
          # Send the final move to the loosingn player
          Serverutils.send(state.player1.socket, "set", slot)

          # Game over
          Serverutils.send(state.player2.socket, "win", nil)
          Serverutils.send(state.player1.socket, "loose", nil)
          {:next_state, :win, state}
        else
          #No win yet
          # Notify the other player about the put...
          Serverutils.send(state.player1.socket, "set", slot)
          
          # ...and give him the next turn.
          Serverutils.send(state.player1.socket, "turn", nil)
          {:next_state, :p1, state}
        end
      true ->
        Logger.warn "Invalid slot: #{slot}"
        {:next_state, :p2, state}
    end
  end

  def p2({_, "restart", _}, state) do
    Logger.warn "Restart not allowed while game is ongoing"
    {:next_state, :p2, state}
  end

  @doc """
  FSM is in state `p1`. Player 1 puts.
  Outcome: p2 state
  """
  def p1({id, "put", slot}, state) do
    cond do
      id != state.player1.id ->
        Logger.warn "Not your turn"
        {:next_state, :p1, state}
      slot in 0..7 ->
        Gamefield.update_field(state.field, slot, :p1)
        if Gamefield.check_win_condition(state.field) do  
          # Set the final move to the loosing player
          Serverutils.send(state.player2.socket, "set", slot)

          # Game over
          Serverutils.send(state.player1.socket, "win", nil)
          Serverutils.send(state.player2.socket, "loose", nil)
          {:next_state, :win, state}
        else
          #No win yet
          # Notify the other player about the put...
          Serverutils.send(state.player2.socket, "set", slot)
          
          # ...and give him the next turn.
          Serverutils.send(state.player2.socket, "turn", nil)
          {:next_state, :p2, state}
        end
      true ->
        Logger.warn "Invalid slot: #{slot}"
        {:next_state, :p1, state}
    end
  end

  def p1({_, "restart", _}, state) do
    Logger.warn "Restart not allowed while game is ongoing"
    {:next_state, :p2, state}
  end

  def win({_, "restart", _}, state) do
    Gamefield.reset_game(state.field)
    Serverutils.send(state.player1.socket, "reset", nil)
    Serverutils.send(state.player2.socket, "reset", nil)
    Serverutils.send(state.player2.socket, "turn", nil)
    {:next_state, :p2, state}
  end
end
