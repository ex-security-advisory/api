use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_security_advisory_api, ElixirSecurityAdvisoryApi.Endpoint,
  http: [port: 4002],
  server: false

config :mnesia, dir: 'Mnesiatest'

config :elixir_security_advisory, ElixirSecurityAdvisory, ElixirSecurityAdvisoryMock

# Print only warnings and errors during test
config :logger, level: :warn
