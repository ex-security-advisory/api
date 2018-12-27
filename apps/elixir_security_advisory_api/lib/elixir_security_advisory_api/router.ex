defmodule ElixirSecurityAdvisoryApi.Router do
  use ElixirSecurityAdvisoryApi, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/", ElixirSecurityAdvisoryApi do
    pipe_through :browser

    get("/", IndexController, :index)
  end

  forward("/v1", ElixirSecurityAdvisoryApiV1.Router)
end
