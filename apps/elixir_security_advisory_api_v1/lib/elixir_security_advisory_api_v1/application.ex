defmodule ElixirSecurityAdvisoryApiV1.Application do
  @moduledoc false

  use Application

  case Mix.env() do
    :test ->
      @workers []

    _ ->
      @workers [
        ElixirSecurityAdvisoryApiV1.PubSubConsumer.Package,
        ElixirSecurityAdvisoryApiV1.PubSubConsumer.Vulnerability
      ]
  end

  def start(_type, _args) do
    Supervisor.start_link(
      @workers,
      strategy: :one_for_one,
      name: ElixirSecurityAdvisoryApiV1.Supervisor
    )
  end
end
