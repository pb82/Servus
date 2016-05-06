use Mix.Config

# Base config
config :servus,
  backends: [:connect_four],
  modules: [Echo, HiScore]

# Configuration for a connect-four game
config :servus,
connect_four: %{
  adapters: [
    tcp: 3334,
    web: 3335
  ],
  players_per_game: 2, 
  implementation: ConnectFour
}

config :servus,
database: %{
  rootpath: "./db"
}

import_config "#{Mix.env}.exs"
