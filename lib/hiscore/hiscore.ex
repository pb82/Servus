defmodule HiScore do
  @moduledoc """
  
  # put sample
  Servus.Serverutils.call("hiscore", "put", %{module: 'sample game', player: 666, score: 1337})
  # get sample
  Servus.Serverutils.call("hiscore", "get", %{module: 'sample game', player: 666})
  # rank sample
  Servus.Serverutils.call("hiscore", "rank", %{module: 'sample game', limit: 10})
  """
  use Servus.Module 
  require Logger

  @config Application.get_env(:servus, :database)
  @db "file:#{@config.rootpath}/hiscore.sqlite3#{@config.testmode}"

  register "hiscore"

  def startup do
    Logger.info "HiScore module registered: #{@db}"

    {:ok, db} = Sqlitex.Server.start_link(@db)

    case Sqlitex.Server.exec(db, "CREATE TABLE IF NOT EXISTS hiscores (module TEXT, player INTEGER, score INTEGER, created_on INTEGER DEFAULT CURRENT_TIMESTAMP)") do
      :ok -> Logger.info "Table hiscores created"
      {:error, {:sqlite_error, 'table hiscores already exists'}} -> Logger.info "Table hiscores already exists"
    end

    %{db: db} # Return module state here - db pid is used in handles
  end

  handlep "put", %{module: _, player: _, score: _} = args , state do
    insert_stmt = "INSERT INTO hiscores(module, player, score) VALUES ('#{args.module}', '#{args.player}', '#{args.score}')"
    Sqlitex.Server.exec(state.db, insert_stmt)
  end

  handlep "get", %{module: _, player: _} = args, state do
    Sqlitex.Server.query(state.db, "SELECT score FROM hiscores WHERE module = '#{args.module}' AND player = '#{args.player}'")
  end

  handlep "rank", %{module: _, limit: _} = args, state do
    Sqlitex.Server.query(state.db, "SELECT score FROM hiscores WHERE module = '#{args.module}' ORDER BY score DESC LIMIT #{args.limit}")
  end
end
