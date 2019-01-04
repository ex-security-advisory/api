defmodule ElixirSecurityAdvisoryApiV1.PackageController do
  use ElixirSecurityAdvisoryApiV1, :controller

  plug :default_pagination, %{"first" => 10} when action in [:index]

  use Absinthe.Phoenix.Controller, schema: ElixirSecurityAdvisoryApiV1.Schema

  swagger_path :index do
    summary("List packages")
    produces("application/json")

    parameter(
      :after,
      :query,
      :string,
      "List entries after cursor"
    )

    parameters do
      first(:query, :integer, "List the first X entries")
      last(:query, :integer, "List the last X entries")
      before(:query, :string, "List entries before cursor")
    end

    response(200, "OK", Schema.ref(:PackageList))

    response(400, "Bad Request")
  end

  swagger_path :show do
    summary("Show package")
    produces("application/json")

    parameters do
      id(
        :path,
        :string,
        "The package id"
      )
    end

    response(200, "OK", Schema.ref(:Package))
    response(404, "Not Found")
  end

  def swagger_definitions do
    %{
      PackageList:
        swagger_schema do
          title("Package List")
          description "List of packages"

          properties do
            edges(
              Schema.new do
                type(:array)

                items(
                  Schema.new do
                    properties do
                      node(Schema.ref(:Package), "Node Object", required: true)
                      cursor(:string, "Cursor", required: true)
                    end
                  end
                )
              end,
              "List of edge nodes"
            )

            pageInfo(Schema.ref(:PageInfo), "Pagination Info", required: true)
          end
        end,
      Package:
        swagger_schema do
          properties do
            id(:string, "Package ID", required: true)
            name(:string, "Package Name", required: true)
          end

          example(%{
            id: "UGFja2FnZTpjb2hlcmVuY2U=",
            name: "coherence"
          })
        end
    }
  end

  @graphql """
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
            name
          }
        }
      }
    }
  """
  def index(conn, %{errors: errors}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:bad_request, Jason.encode!(errors))
  end

  def index(conn, %{data: %{"packages" => packages}}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Jason.encode!(packages))
  end

  @graphql """
    query Package($id: ID!) {
      node(id: $id) {
        id
        __typename
        ... on Package {
          name
        }
      }
    }
  """
  def show(conn, %{errors: errors}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:bad_request, Jason.encode!(errors))
  end

  def show(conn, %{data: %{"node" => %{"__typename" => type}}}) when type != "Package" do
    conn
    |> put_status(:not_found)
    |> put_view(ElixirSecurityAdvisoryApi.ErrorView)
    |> render("404.json")
  end

  def show(conn, %{data: %{"node" => nil}}) do
    conn
    |> put_status(:not_found)
    |> put_view(ElixirSecurityAdvisoryApi.ErrorView)
    |> render("404.json")
  end

  def show(conn, %{data: %{"node" => node}}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Jason.encode!(node))
  end
end
