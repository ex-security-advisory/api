defmodule ElixirSecurityAdvisoryApiV1.Schema.Query.NodeTest do
  @moduledoc false

  use ElixirSecurityAdvisoryApiV1.GraphQLCase

  import Mox

  setup :verify_on_exit!

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      __typename
    }
  }
  """

  test "loads vulnerability" do
    stub(ElixirSecurityAdvisoryMock, :get_vulnerability, fn "7" ->
      %{id: "7", package_id: "xain", revisions: []}
    end)

    node_id = global_id(:vulnerability, "7")

    assert result = run!(@query, variables: %{"id" => node_id})

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{"__typename" => "Vulnerability"}
             }
           } = result
  end

  test "loads package" do
    stub(ElixirSecurityAdvisoryMock, :get_package, fn "7" ->
      %{id: "7", name: "xain"}
    end)

    node_id = global_id(:package, "7")

    assert result = run!(@query, variables: %{"id" => node_id})

    assert_no_error(result)

    assert %{
             data: %{
               "node" => %{"__typename" => "Package"}
             }
           } = result
  end
end
