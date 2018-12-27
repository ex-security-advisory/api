defmodule ElixirSecurityAdvisoryApiV1.PubSubConsumer.Package do
  @moduledoc """
  Relay messages from ElixirSecurityAdvisory PubSub to Subscriptions
  """

  use GenServer

  @vulnerabilities Application.fetch_env!(:elixir_security_advisory, ElixirSecurityAdvisory)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    @vulnerabilities.subscribe_package(link: true)

    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:added, %{} = package}, state) do
    Absinthe.Subscription.publish(
      ElixirSecurityAdvisoryApi.Endpoint,
      package,
      package_added: :*
    )

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
