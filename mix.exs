defmodule Azalea.Mixfile do
  use Mix.Project

  def project do
    [
      app: :azalea,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test,
                          "coveralls.detail": :test,
                          "coveralls.post": :test,
                          "coveralls.html": :test],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger,
        :httpoison,
        :plug
      ]
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
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"},
      {:plug, "~> 1.2.2"},
      {:cowboy, "~> 1.0.4"},
      {:ecto, "~> 2.0"},

      {:mix_test_watch, "~> 0.2", only: :dev},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},

      {:meck, "~> 0.8.2", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:httparrot, "~> 0.5", only: :test},

      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
