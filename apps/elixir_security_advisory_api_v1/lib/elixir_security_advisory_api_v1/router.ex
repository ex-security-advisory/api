defmodule ElixirSecurityAdvisoryApiV1.Router do
  use ElixirSecurityAdvisoryApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirSecurityAdvisoryApiV1 do
    pipe_through :api

    get("/", IntroductionController, :index)

    resources "/packages", PackageController, only: [:index, :show]
    resources "/vulnerabilities", VulnerabilityController, only: [:index, :show]

    resources "/packages/:id/vulnerabilities", PackageVulnerabilityController, only: [:index]
  end

  forward "/swagger", PhoenixSwagger.Plug.SwaggerUI,
    otp_app: :elixir_security_advisory_api_v1,
    swagger_file: "swagger.json"

  forward(
    "/graphiql",
    Absinthe.Plug.GraphiQL,
    schema: ElixirSecurityAdvisoryApiV1.Schema,
    socket: ElixirSecurityAdvisoryApiV1.UserSocket,
    pipeline: {ApolloTracing.Pipeline, :plug},
    interface: :playground,
    init_opts: [json_codec: Jason]
  )

  forward(
    "/graphql",
    Absinthe.Plug,
    schema: ElixirSecurityAdvisoryApiV1.Schema,
    socket: ElixirSecurityAdvisoryApiV1.UserSocket,
    pipeline: {ApolloTracing.Pipeline, :plug},
    init_opts: [json_codec: Jason]
  )

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Elixir Security Advisory"
      },
      basePath: "/v1"
    }
  end
end
