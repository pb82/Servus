defmodule Servus.Mixfile do
  use Mix.Project

  def project do
    [app: :servus,
     version: "0.0.1",
     elixir: "~> 1.1",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:crypto, :logger],
      mod: {Servus, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:poison, "~> 2.1.0"},
      {:socket, "~> 0.3.4"}
    ]
  end
end
