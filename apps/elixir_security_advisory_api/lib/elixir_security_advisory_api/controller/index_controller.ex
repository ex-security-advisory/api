defmodule ElixirSecurityAdvisoryApi.IndexController do
  @moduledoc false

  use ElixirSecurityAdvisoryApi, :controller

  alias ElixirSecurityAdvisoryApiV1.Router.Helpers, as: Routes

  def index(conn, _args) do
    redirect(conn, to: Routes.introduction_path(conn, :index))
  end
end
