defmodule ZServer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :zserver,
      version: "0.1.0",
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ZServer, []},
      applications: applications(Mix.env)
    ]
  end

  defp applications(:dev), do: applications(:all) ++ [:exsync]
  defp applications(_all) do
    [:logger, :maru]
    ++ [:cqerl, :uuid, :semver, :pooler, :lz4, :snappy]
  end

  defp elixirc_paths(_all), do: ["lib", "src"]

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
      {:cowboy, "~> 1.0.0"},
      {:maru, git: "https://github.com/falood/maru.git", branch: "master"},
      {:cqerl, git: "https://github.com/matehat/cqerl.git", tag: "v0.8.0"},
      {:exrm, git: "https://github.com/bitwalker/exrm.git", tag: "0.19.2"},
      {:exsync, "~> 0.1.0", only: :dev},
      {:espec, "~> 0.6.4", only: :test},
    ]
  end
end
