defmodule Servus do
  @moduledoc"""
  The `Servus` Game Server
  A simple, modular and universal game backend
  """
  
  use Application
  
  # Entry point
  def start(_type, _args) do
    Servus.Supervisor.start_link
  end
end
