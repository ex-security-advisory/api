defmodule ElixirSecurityAdvisoryApiV1.PackageControllerTest do
  @moduledoc false

  use ElixirSecurityAdvisoryApi.ConnCase
  use ElixirSecurityAdvisoryApiV1.GraphQLCase

  import Mox

  alias ElixirSecurityAdvisoryApiV1.Router.Helpers, as: Routes

  describe "index" do
    test "loads list", %{conn: conn} do
      stub(ElixirSecurityAdvisoryMock, :list_packages, fn ->
        [%{id: "xain", name: "xain"}]
      end)

      assert resp = get(conn, "/v1/" <> Routes.package_path(conn, :index, first: 10))

      assert json_response(resp, :ok)
    end
  end

  describe "show" do
    test "loads detail", %{conn: conn} do
      stub(ElixirSecurityAdvisoryMock, :get_package, fn _id ->
        %{id: "xain", name: "xain"}
      end)

      assert resp =
               get(
                 conn,
                 "/v1/" <>
                   Routes.package_path(
                     conn,
                     :show,
                     global_id(:package, "xain")
                   )
               )

      assert json_response(resp, :ok)
    end

    test "not found", %{conn: conn} do
      stub(ElixirSecurityAdvisoryMock, :get_package, fn _id ->
        nil
      end)

      assert resp =
               get(
                 conn,
                 "/v1/" <>
                   Routes.package_path(
                     conn,
                     :show,
                     global_id(:package, "xain")
                   )
               )

      assert json_response(resp, :not_found)
    end

    test "invalid id", %{conn: conn} do
      assert resp =
               get(
                 conn,
                 "/v1/" <>
                   Routes.vulnerability_path(
                     conn,
                     :show,
                     "foo"
                   )
               )

      assert json_response(resp, :not_found)
    end

    test "wrong resource id", %{conn: conn} do
      stub(ElixirSecurityAdvisoryMock, :get_vulnerability, fn _id ->
        %{
          id: "packages/coherence/2017-08-02.yml",
          package_id: "coherence",
          revisions: [
            %{
              cve: nil,
              description:
                "The Coherence library has \"Mass Assignment\"-like vulnerabilities. In particular, \"registration\"\nendpoints (like creating, editing, updating), allow users to update any coherence_fields. This\nmeans that, among other issues, users can automatically confirm their accounts by sending the\nconfirmed_at parameter with their registration request. Further, the library design and\ndocumentation encourages insecure functionality by default.\n\nFor example, the \"store\" demo allows registering users to add themselves as admin:\nhttps://github.com/smpallen99/store/blob/master/web/models/coherence/user.ex",
              disclosure_date: nil,
              link: %URI{
                authority: "github.com",
                fragment: nil,
                host: "github.com",
                path: "/smpallen99/coherence/issues/270",
                port: 443,
                query: nil,
                scheme: "https",
                userinfo: nil
              },
              newest_revision_id: nil,
              oldest_revision_id: "4a69ca0aa7367ce6265d95c9f72f95039cc5a86e",
              patched_versions: nil,
              revision_message: "Add coherence issue",
              title: "Permissive parameters and privilege escalation",
              unaffected_versions: nil
            }
          ]
        }
      end)

      stub(ElixirSecurityAdvisoryMock, :get_package_by_vulnerability, fn _vuln ->
        %{
          id: "coherence",
          name: "coherence"
        }
      end)

      assert resp =
               get(
                 conn,
                 "/v1/" <>
                   Routes.package_path(
                     conn,
                     :show,
                     global_id(:vulnerability, "packages/coherence/2017-08-02.yml")
                   )
               )

      assert json_response(resp, :not_found)
    end
  end
end
