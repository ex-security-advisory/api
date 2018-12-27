defmodule ElixirSecurityAdvisoryApiV1.Schema.Query.PackagesTest do
  @moduledoc false

  use ElixirSecurityAdvisoryApiV1.GraphQLCase

  import Mox

  setup :verify_on_exit!

  @query """
  query Packages($first: Int, $last: Int, $before: String, $after: String) {
    packages(first: $first, last: $last, before: $before, after: $after) {
      pageInfo {
        endCursor
        startCursor
        hasNextPage
        hasPreviousPage
      }
      edges {
        cursor
        node {
          id
        }
      }
    }
  }
  """

  test "loads list" do
    stub(ElixirSecurityAdvisoryMock, :list_packages, fn ->
      [%{id: "xain"}]
    end)

    node_id = global_id(:package, "xain")

    assert result = run!(@query, variables: %{"first" => 10})

    assert_no_error(result)

    assert %{
             data: %{
               "packages" => %{"edges" => [%{"node" => %{"id" => ^node_id}}]}
             }
           } = result
  end
end
