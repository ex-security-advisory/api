defmodule ElixirSecurityAdvisoryApiV1.Plug.Accept do
  @moduledoc false

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(options) do
    [{_, default} | _] =
      accepts =
      for {accept, {plug, plug_options}} <- Keyword.fetch!(options, :accept) do
        {accept, {plug, plug.init(plug_options)}}
      end

    {Enum.into(accepts, %{}), default}
  end

  @impl Plug
  def call(conn, {accepts, default}) do
    {plug, options} =
      conn
      |> get_req_header("accept")
      |> Enum.map(&:accept_header.negotiate(&1, Map.keys(accepts)))
      |> Enum.reject(&(&1 == :undefined))
      |> case do
        [] -> default
        [selected | _] -> Map.fetch!(accepts, selected)
      end

    plug.call(conn, options)
  end
end
