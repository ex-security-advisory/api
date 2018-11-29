defmodule ElixirSecurityAdvisoryApi.Router do
  use ElixirSecurityAdvisoryApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElixirSecurityAdvisoryApi do
    pipe_through :api
  end
end
