use Mix.Config

# Base config
config :servus,
  backends: [:connect_four],
  modules: [Echo]

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

import_config "#{Mix.env()}.exs"
