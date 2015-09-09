use Mix.Config

# Base config
config :base,
  backends: [:connect_four],
  modules: [Echo]
  
# Configuration for a connect-four game
config :connect_four, 
  port: 3334,
  players_per_game: 2,
  implementation: ConnectFour
