use Mix.Config

# Base config
config :servus
  backends: [:connect_four],
  modules: [Echo]

# Configuration for a connect-four game
config :servus,
connect_four: %{port: 3334, players_per_game: 2, implementation: ConnectFour}
