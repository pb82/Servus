defmodule HiScore do
  @moduledoc """
  
  # put sample
  Servus.Serverutils.call("hiscore", "put", %{module: 'sample game', player: 'gamer number one', 1337})
  # get sample
  Servus.Serverutils.call("hiscore", "get", %{module: 'sample game', player: 'gamer number one'})
  # rank sample
  Servus.Serverutils.call("hiscore", "rank", %{module: 'sample game', limit: 10})
  """
  use Servus.Module 
  require Logger

  @config Application.get_env(:servus, :database)
  @db "#{@config.rootpath}/hiscore.sqlite3"

  register "hiscore"

  def startup do
    Logger.info "HiScore module registered: #{@db}"

    {:ok, db} = Sqlitex.Server.start_link(@db)

    case Sqlitex.Server.exec(db, "CREATE TABLE hiscores (module TEXT, player TEXT, score INTEGER, date INTEGER)") do
      :ok -> Logger.info "Table hiscores created"
      {:error, {:sqlite_error, 'table hiscores already exists'}} -> Logger.info "Table hiscores already exists"
    end

    %{db: db} # Return module state here - db pid is used in handles
  end

  handlep "put", %{module: _, player: _, score: _} = args , state do
    insert_stmt = "INSERT INTO hiscores VALUES ('#{args.module}', '#{args.player}', '#{args.score}', CURRENT_TIMESTAMP)"
    Sqlitex.Server.exec(state.db, insert_stmt)
  end

  handlep "get", %{module: _, player: _} = args, state do
    Sqlitex.Server.query(state.db, "SELECT score FROM hiscores WHERE module = '#{args.module}' AND player = '#{args.player}'")
  end

  handlep "rank", %{module: _, limit: _} = args, state do
    Sqlitex.Server.query(state.db, "SELECT score FROM hiscores WHERE module = '#{args.module}' ORDER BY score DESC LIMIT #{args.limit}")
  end
end
