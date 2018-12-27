defmodule ElixirSecurityAdvisoryApiV1.GraphQLCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require GraphQL.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias ElixirSecurityAdvisoryApi.Endpoint
  alias ElixirSecurityAdvisoryApiV1.Schema

  using do
    quote do
      import unquote(__MODULE__)
      use Absinthe.Phoenix.SubscriptionTest, schema: ElixirSecurityAdvisoryApiV1.Schema
      use ElixirSecurityAdvisoryApi.ChannelCase

      setup do
        {:ok, socket} =
          nil
          |> socket
          |> join_absinthe

        {:ok, socket: socket}
      end
    end
  end

  def run(input, options \\ []) do
    options = options |> Keyword.put_new(:context, %{}) |> put_in([:context, :pubsub], Endpoint)
    Absinthe.run(input, Schema, options)
  end

  def run!(input, options \\ []) do
    options = options |> Keyword.put_new(:context, %{}) |> put_in([:context, :pubsub], Endpoint)
    Absinthe.run!(input, Schema, options)
  end

  def assert_no_error(result), do: refute(Map.has_key?(result, :errors))

  def global_id(node_type, source_id),
    do: Absinthe.Relay.Node.to_global_id(node_type, source_id, Schema)
end
