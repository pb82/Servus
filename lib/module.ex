defmodule Servus.Module do
  @moduledoc """
  A macro for server modules. Modules can implement tasks other
  than game logic. For example storing hiscores.
  """
  defmacro __using__(_) do
    quote do
      use GenServer
      import Servus.Module

      def start_link(args) do
        GenServer.start_link(__MODULE__, [], args)
      end
  
      def init(args) do
        __register__
        {:ok, startup}
      end

      def terminate(reason, state) do
        shutdown(state)
        :ok
      end

      # ###############
      # Callbacks
      # ###############

      def startup do
        # Override in user code
        []
      end

      def shutdown(_state) do
        # Override in user code
      end

      def __register__ do
        # Override or die
        raise "Did you forget to register module  #{__MODULE__}?"
      end

      defoverridable [__register__: 0, startup: 0, shutdown: 1]
    end
  end

  defmacro register(name) do
    quote do
      def __register__ do
        ModuleStore.register(unquote(name), self())
      end
    end
  end

  @doc """
  Handle a message that is sent to the module This implements
  a handler that is called with arguments. It takes a `state` argument
  (which may be ignored).
  """
  defmacro handle(action, args, state, handler) do
    handler_impl = Keyword.get(handler, :do, nil)
 
    # Normalize state
    # (let the user ignore the state with _ if he wants)
    state = case state do
      {:_, a, b} -> {:state, a, b}
      _ -> state
    end

    quote do
      def handle_call({unquote(action), unquote(args)}, _from, unquote(state)) do
        result = (unquote(handler_impl))
        {:reply, result, unquote(state)}
      end
    end
  end

  @doc """
  Handle a private message that is sent to the module. This implements
  a handler that can only be called from within the server (a game logic
  for example). It can't be called from a client. Operations that are not
  save for clients to execute (because they might abuse them) should be
  handled privately.
  """
  defmacro handlep(action, args, state, handler) do
    handler_impl = Keyword.get(handler, :do, nil)
 
    # Normalize state
    # (let the user ignore the state with _ if he wants)
    state = case state do
      {:_, a, b} -> {:state, a, b}
      _ -> state
    end

    quote do
      def handle_call({:priv, unquote(action), unquote(args)}, _from, unquote(state)) do
        result = (unquote(handler_impl))
        {:reply, result, unquote(state)}
      end
    end
  end
end
