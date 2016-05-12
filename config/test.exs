use Mix.Config

config :logger,
  level: :info

config :servus,
database: %{
  rootpath: "./db",
  testmode: "?mode=memory"
}