defmodule ElixirSecurityAdvisoryGithubSource.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :elixir_security_advisory_github_source,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
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
      extra_applications: [:logger],
      mod: {ElixirSecurityAdvisoryGithubSource.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_security_advisory, in_umbrella: true},
      {:github, "~> 0.10"},
      {:yamerl, "~> 0.7.0"},
      {:exvcr, "~> 0.10", only: :test},
      {:mox, "~> 0.4", only: :test},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
