# Since configuration is shared in umbrella projects, this file
# should only configure the :elixir_security_advisory_api application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :elixir_security_advisory_api,
  generators: [context_app: :elixir_security_advisory]

# Configures the endpoint
config :elixir_security_advisory_api, ElixirSecurityAdvisoryApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wFnmtlHD7atLxdY88n1GXVyI1vgg4tqUjAAa7fdYkNs7J1oPRKnx2u0qZAM2upoH",
  render_errors: [view: ElixirSecurityAdvisoryApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: ElixirSecurityAdvisoryApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
