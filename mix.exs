defmodule ZServer.Mixfile do
  use Mix.Project

  def project do
    [app: :ZServer,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ZServer, []},
      applications: [:cowboy, :plug]
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
      { :cowboy, "~> 1.0.0" },
      { :plug, "~> 0.13" },
      { :jsx, "~> 2.6.2" }
    ]
  end
end
