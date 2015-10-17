defmodule Servus.PidStore do
  @moduledoc """
  Stores the currently running game logic pids per player.
  """
  def start_link do
    Agent.start_link fn -> HashDict.new end, name: __MODULE__
  end

  def put(player, pid) do
    Agent.update __MODULE__, fn dict -> HashDict.put(dict, player, pid) end
  end

  def get(player) do
    Agent.get __MODULE__, fn dict -> HashDict.get(dict, player) end
  end

  def remove(player) do
    Agent.update __MODULE__, fn dict -> HashDict.delete(dict, player) end
  end
end

defmodule Servus.ModuleStore do
  @moduledoc """
  Stores the pids of running modules.
  """
  def start_link do
    Agent.start_link fn -> HashDict.new end, name: __MODULE__
  end

  def register(module, pid) do
    Agent.update __MODULE__, fn dict -> HashDict.put(dict, module, pid) end
  end

  def get(module) do
    Agent.get __MODULE__, fn dict -> HashDict.get(dict, module) end
  end
end
