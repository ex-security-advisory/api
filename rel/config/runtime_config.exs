use Mix.Config

# Import normal overlayed configuration file. See the distillery configuration
# for more details.
import_config "config.exs"

# Configures the endpoint
config :elixir_security_advisory_api, ElixirSecurityAdvisoryApi.Endpoint,
  server: true,
  code_reloader: false
