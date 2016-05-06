defmodule HiScore do
  use Servus.Module 
  require Logger

  @config Application.get_env(:servus, :database)

  register "hiscore"

  def startup do
    Logger.info "HiScore module registered: #{@config.rootpath}"
    [] # Return module state here
  end

  handle "put", args, state do
    args
  end
end
