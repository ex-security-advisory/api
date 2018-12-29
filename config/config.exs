# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elixir_security_advisory, ElixirSecurityAdvisory, ElixirSecurityAdvisory.Vulnerabilities

# General application configuration
config :elixir_security_advisory_api,
  generators: [context_app: :elixir_security_advisory]

# Configures the endpoint
config :elixir_security_advisory_api, ElixirSecurityAdvisoryApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wFnmtlHD7atLxdY88n1GXVyI1vgg4tqUjAAa7fdYkNs7J1oPRKnx2u0qZAM2upoH",
  render_errors: [view: ElixirSecurityAdvisoryApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: ElixirSecurityAdvisoryApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :elixir_security_advisory_github_source, ElixirSecurityAdvisoryGithubSource.Poller,
  repository: [
    repo_path: "dependabot/elixir-security-advisories",
    path: "packages",
    branch: "master"
  ],
  access_token: System.get_env("GITHUB_ACCESS_TOKEN")

config :elixir_security_advisory_api_v1, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: ElixirSecurityAdvisoryApiV1.Router
      # (optional) endpoint config used to set host, port and https schemes.
      # endpoint: ElixirSecurityAdvisoryApi.Endpoint
    ]
  }

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Clustering for Gigalixir
if System.get_env("LIBCLUSTER_KUBERNETES_SELECTOR") ||
     System.get_env("LIBCLUSTER_KUBERNETES_NODE_BASENAME") do
  config :libcluster,
    topologies: [
      k8s_example: [
        strategy: Cluster.Strategy.Kubernetes,
        config: [
          kubernetes_selector: System.get_env("LIBCLUSTER_KUBERNETES_SELECTOR"),
          kubernetes_node_basename: System.get_env("LIBCLUSTER_KUBERNETES_NODE_BASENAME")
        ]
      ]
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
