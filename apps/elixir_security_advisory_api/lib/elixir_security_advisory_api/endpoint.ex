defmodule ElixirSecurityAdvisoryApi.Endpoint do
  use Phoenix.Endpoint, otp_app: :elixir_security_advisory_api
  use Absinthe.Phoenix.Endpoint

  require PlugDynamic.Builder

  case Mix.env() do
    :test ->
      nil

    _ ->
      PlugDynamic.Builder.dynamic_plug PlugCanonicalHost do
        [
          canonical_host:
            :elixir_security_advisory_api
            |> Application.fetch_env!(__MODULE__)
            |> Keyword.fetch!(:url)
            |> Keyword.fetch!(:host)
        ]
      end
  end

  socket "/v1/socket", ElixirSecurityAdvisoryApiV1.UserSocket,
    websocket: true,
    longpoll: true

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :elixir_security_advisory_api,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  plug Plug.Static,
    at: "/v1",
    from: :elixir_security_advisory_api_v1,
    gzip: false,
    only: ~w(css fonts images js swagger.json)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug(CORSPlug, origin: [:self])

  plug ElixirSecurityAdvisoryApi.Router
end
