defmodule ElixirSecurityAdvisoryApiV1.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :elixir_security_advisory_api_v1,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext, :phoenix_swagger] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixirSecurityAdvisoryApiV1.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.13"},
      {:gettext, "~> 0.11"},
      {:cors_plug, "~> 2.0"},
      {:apollo_tracing, "~> 0.4.0"},
      {:absinthe_phoenix, "~> 1.4"},
      {:absinthe, "~> 1.4"},
      {:absinthe_relay, "~> 1.4"},
      {:elixir_security_advisory, in_umbrella: true},
      {:elixir_security_advisory_api, in_umbrella: true},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_swagger, "~> 0.8"},
      {:mox, "~> 0.4", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:accept, "~> 0.3"}
    ]
  end
end
