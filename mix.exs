defmodule ZServer.Mixfile do
  use Mix.Project

  def project do
    [app: :ZServer,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ZServer, []},
      applications: [:maru, :exsync, :cqerl, :ibrowse]
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
      { :maru, git: "https://github.com/falood/maru.git", branch: "master" },
      { :maru_swagger, git: "https://github.com/upbit/maru_swagger.git", branch: "master" },
      { :exsync, "~> 0.1.0" },
      { :cqerl, git: "https://github.com/matehat/cqerl.git", tag: "v0.8.0" },
      { :tesla, "~> 0.1.5" },
      { :ibrowse, git: "https://github.com/cmullaparthi/ibrowse.git", tag: "v4.1.1"},
      { :exjsx, "~> 3.1.0" },
    ]
  end
end
