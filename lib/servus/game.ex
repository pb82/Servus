defmodule Servus.Game do
  @moduledoc """
  A macro to be used with game state-machines. Will automatically
  start the state machine via the provided `start` function.
  """
  defmacro __using__(_) do
    quote do
      use GenStateMachine

      def start(players) do
        {:ok, pid} = GenStateMachine.start(__MODULE__, players, [])
        pid
      end

      @doc """
      Forward all abort events (player aborts connection) to the
      appropriate handler function (abort).
      """
      def handle_event(:cast, {:abort, player}, _, state) do
        abort(player, state)
      end

      @doc """
      Default empty `terminate` implementation to allow game
      state machines to shutdown gracefully.
      """
      def terminate(_reason, _stateName, _stateData) do
        # This functin intentionally left blank
      end

      @doc """
      Overridable by user. Will be invoked when one of the players
      aborts the connection.
      """
      def abort(player, state) do
        # Default: stop game state machine on connection abort
        # :gem_statem.close(self)
        {:stop, :shutdown, state}
      end

      defoverridable abort: 2
    end
  end
end
