defmodule TwitchChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitch_chat,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TwitchChat.Application, []},
      application: :httpoison,
      extra_applications: [:logger]
    ]
  end

  def aliases do
    [
      quality: [
        "credo --strict",
        "sobelow -i XSS.Raw,Traversal --verbose --exit Low",
        # "dialyzer",
        "test"
      ]
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.2"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dotenv, "~> 3.0.0"},
      {:exirc, "~> 2.0"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
