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
        Servus.ModuleStore.register(unquote(name), self())
      end
    end
  end

  @doc """
  Handle a message that is sent to the module. This implements
  a handler without arguments. This implementation does not 
  take a state argument and is only usable for very simple modules.
  """
  defmacro handle(action, handler) do
    handler_impl = Keyword.get(handler, :do, nil)
    
    quote do
      def handle_call({unquote(action), _}, _from, state) do
        result = (unquote(handler_impl))
        {:reply, result, state}
      end
    end
  end

  @doc """
  Handle a message that is sent to the module. This implements
  a handler without arguments. It takes a `state` argument (which
  may be ignored)
  """
  defmacro handle(action, state, handler) do
    handler_impl = Keyword.get(handler, :do, nil)
    
    # Normalize state
    # (let the user ignore the state with _ if he wants)
    state = case state do
      {:_, a, b} -> {:state, a, b}
      _ -> state
    end

    quote do
      def handle_call({unquote(action), _}, _from, unquote(state)) do
        result = (unquote(handler_impl))
        {:reply, result, unquote(state)}
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
end
