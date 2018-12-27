defmodule ElixirSecurityAdvisoryApiV1.IntroductionController do
  use ElixirSecurityAdvisoryApiV1, :controller

  def index(conn, _args) do
    render(conn, "index.html")
  end
end
