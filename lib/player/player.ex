defmodule Player do
  @moduledoc """
  
  """
  use Servus.Module 
  require Logger

  @config Application.get_env(:servus, :database)
  @db "file:#{@config.rootpath}/player.sqlite3#{@config.testmode}"


  register "player"

  def startup do
    Logger.info "Player module registered: #{@db}"

    {:ok, db} = Sqlitex.Server.start_link(@db)

    case Sqlitex.Server.exec(db, "CREATE TABLE IF NOT EXISTS players (id INTEGER PRIMARY KEY AUTOINCREMENT, nick TEXT, facebook_token TEXT, facebook_id TEXT UNIQUE, facebook_mail TEXT UNIQUE, login_name TEXT UNIQUE, login_hash  TEXT, login_mail TEXT UNIQUE, created_on INTEGER DEFAULT CURRENT_TIMESTAMP)") do
      :ok -> Logger.info "Table players created"
      {:error, {:sqlite_error, 'table players  already exists'}} -> Logger.info "Table players already exists"
    end

    %{db: db} # Return module state here - db pid is used in handles
  end

  handlep "put", %{nick: _} = args , state do
    Logger.info "Player module insert_stmt"
    insert_stmt = "INSERT INTO players(nick) VALUES ('#{args.nick}')"
    Sqlitex.Server.exec(state.db, insert_stmt)
  end

  handlep "reg_with_facebook", %{facebook_name: _, facebook_token: _, facebook_id: _, facebook_mail: _} = args , state do
    Logger.info "Player module reg_with_facebook"
    insert_stmt = "INSERT INTO players (nick,facebook_token,facebook_id,facebook_mail) VALUES ('#{args.facebook_name}','#{args.facebook_token}','#{args.facebook_id}','#{args.facebook_mail}')"
    Sqlitex.Server.exec(state.db, insert_stmt)
  end

  handlep "select_facebook", %{facebook_id: _} = args , state do
    Logger.info "Player module select_facebook"
    select_stmt = "Select * FROM players  where facebook_id = '#{args.facebook_id}'"
    Sqlitex.Server.query(state.db, select_stmt)
  end
   handlep "delete_facebook", %{facebook_id: _} = args , state do
    Logger.info "Player module delete_facebook"
    select_stmt = "Delete FROM players  where facebook_id = '#{args.facebook_id}'"
    Sqlitex.Server.query(state.db, select_stmt)
  end
end
