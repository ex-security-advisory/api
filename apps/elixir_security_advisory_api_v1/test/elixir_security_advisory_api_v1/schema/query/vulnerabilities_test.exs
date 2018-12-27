defmodule ElixirSecurityAdvisoryApiV1.Schema.Query.VulnerabilitiesTest do
  @moduledoc false

  use ElixirSecurityAdvisoryApiV1.GraphQLCase

  import Mox

  setup :verify_on_exit!

  @query """
  query Vulnerabilities($affectsVersion: Version, $packageName: String, $first: Int, $last: Int, $before: String, $after: String) {
    vulnerabilities(first: $first, last: $last, before: $before, after: $after, affectsVersion: $affectsVersion, packageName: $packageName) {
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
    stub(ElixirSecurityAdvisoryMock, :list_vulnerabilities, fn ->
      [%{id: "xain/2018-01-01.yml"}]
    end)

    node_id = global_id(:vulnerability, "xain/2018-01-01.yml")

    assert result = run!(@query, variables: %{"first" => 10})

    assert_no_error(result)

    assert %{
             data: %{
               "vulnerabilities" => %{"edges" => [%{"node" => %{"id" => ^node_id}}]}
             }
           } = result
  end

  test "by package existing" do
    stub(ElixirSecurityAdvisoryMock, :get_package_by_name, fn "xain" ->
      %{id: "xain"}
    end)

    stub(ElixirSecurityAdvisoryMock, :list_vulnerabilities_by_package, fn %{id: "xain"} ->
      [%{id: "xain/2018-01-01.yml"}]
    end)

    node_id = global_id(:vulnerability, "xain/2018-01-01.yml")

    assert result = run!(@query, variables: %{"first" => 10, "packageName" => "xain"})

    assert_no_error(result)

    assert %{
             data: %{
               "vulnerabilities" => %{"edges" => [%{"node" => %{"id" => ^node_id}}]}
             }
           } = result
  end

  test "by package and affected version" do
    stub(ElixirSecurityAdvisoryMock, :get_package_by_name, fn "xain" ->
      %{id: "xain"}
    end)

    stub(ElixirSecurityAdvisoryMock, :list_vulnerabilities_by_package, fn %{id: "xain"} ->
      [
        %{
          id: "xain/2018-01-01.yml",
          revisions: [%{unaffected_versions: nil, patched_versions: nil}]
        }
      ]
    end)

    node_id = global_id(:vulnerability, "xain/2018-01-01.yml")

    assert result =
             run!(
               @query,
               variables: %{"first" => 10, "packageName" => "xain", "affectsVersion" => "1.2.3"}
             )

    assert_no_error(result)

    assert %{
             data: %{
               "vulnerabilities" => %{"edges" => [%{"node" => %{"id" => ^node_id}}]}
             }
           } = result
  end

  test "by package not existing" do
    stub(ElixirSecurityAdvisoryMock, :get_package_by_name, fn "other package" ->
      nil
    end)

    assert result = run!(@query, variables: %{"first" => 10, "packageName" => "other package"})

    assert_no_error(result)

    assert %{data: %{"vulnerabilities" => %{"edges" => []}}} = result
  end
end
