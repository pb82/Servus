use Mix.Config

# Base config
config :servus,
  backends: [:connect_four, :connect_four_web],
  modules: [Echo]

# Configuration for a connect-four game
config :servus,
connect_four: %{
  port: 3334,
  type: :tcp,
  players_per_game: 2, 
  implementation: ConnectFour
}

config :servus,
connect_four_web: %{
  port: 3335,
  type: :web,
  players_per_game: 2, 
  implementation: ConnectFour
}

import_config "#{Mix.env}.exs"
