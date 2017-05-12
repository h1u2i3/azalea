defmodule Azalea.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :azalea,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test,
                          "coveralls.detail": :test,
                          "coveralls.post": :test,
                          "coveralls.html": :test],
      docs: [extras: ["README.md"], main: "readme",
       source_ref: "v#{@version}",
       source_url: "https://github.com/h1u2i3/azalea"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [
        :logger,
        :httpoison,
        :plug
      ]
    ]
  end

  defp description do
    """
    Azalea is aim to make upload file in Phoenix easy.
    """
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
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 3.0"},
      {:plug, "~> 1.3.5"},
      {:cowboy, "~> 1.1.2"},
      {:ecto, "~> 2.1"},

      {:mix_test_watch, "~> 0.2", only: :dev},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},

      {:meck, "~> 0.8.2", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:httparrot, "~> 1.0.0", only: :test},

      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      name: :azalea,
      maintainers: ["h1u2i3"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/h1u2i3/azalea"}
    ]
  end
end
