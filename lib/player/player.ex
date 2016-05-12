defmodule Player do
  @moduledoc """
  
  """
  use Servus.Module 
  require Logger

  @config Application.get_env(:servus, :database)
  @db "#{@config.rootpath}/player.sqlite3"

  register "player"

  def startup do
    Logger.info "Player module registered: #{@db}"

    {:ok, db} = Sqlitex.Server.start_link(@db)

    case Sqlitex.Server.exec(db, "CREATE TABLE IF NOT EXISTS players (id INTEGER PRIMARY KEY AUTOINCREMENT, nick TEXT, created_on INTEGER DEFAULT CURRENT_TIMESTAMP)") do
      :ok -> Logger.info "Table players created"
      {:error, {:sqlite_error, 'table players  already exists'}} -> Logger.info "Table players already exists"
    end

    %{db: db} # Return module state here - db pid is used in handles
  end

  handlep "put", %{nick: _} = args , state do
    insert_stmt = "INSERT INTO players(nick) VALUES ('#{args.nick}')"
    Sqlitex.Server.exec(state.db, insert_stmt)
  end

  handlep "add_facebook", %{player: _, facebook_token: _} = args , state do
    insert_stmt = "UPDATE players SET facebook_token = #{args.facebook_token} WHERE id = #{args.player}"
    Sqlitex.Server.exec(state.db, insert_stmt)
  end
end
