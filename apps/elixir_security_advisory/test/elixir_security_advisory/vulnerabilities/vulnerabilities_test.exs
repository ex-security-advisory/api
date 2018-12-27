defmodule ElixirSecurityAdvisory.VulnerabilitiesTest do
  @moduledoc false

  use ElixirSecurityAdvisory.DataCase

  alias ElixirSecurityAdvisory.Vulnerabilities

  alias ElixirSecurityAdvisory.Vulnerabilities.Database.{Package, Vulnerability}

  def vulnerability_fixture do
    vulnerability = %{
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

    Vulnerabilities.create_vulnerability(vulnerability)
    vulnerability
  end

  describe "packages" do
    test "list_packages/0 returns all packages" do
      vulnerability_fixture()

      assert Vulnerabilities.transaction(fn ->
               Vulnerabilities.list_packages() |> Enum.to_list()
             end) == [%Package{id: "coherence", name: "coherence"}]
    end

    test "get_package/1 returns package" do
      vulnerability_fixture()

      assert Vulnerabilities.get_package("coherence") == %Package{
               id: "coherence",
               name: "coherence"
             }
    end

    test "get_package/1 returns nil if not found" do
      assert Vulnerabilities.get_package("other") == nil
    end

    test "get_package_by_name/1 returns package" do
      vulnerability_fixture()

      assert Vulnerabilities.get_package_by_name("coherence") == %Package{
               id: "coherence",
               name: "coherence"
             }
    end

    test "get_package_by_name/1 returns nil if not found" do
      assert Vulnerabilities.get_package_by_name("other") == nil
    end
  end

  describe "revisions" do
    test "revision_exists/1 returns true" do
      vulnerability_fixture()

      assert Vulnerabilities.revision_exists("4a69ca0aa7367ce6265d95c9f72f95039cc5a86e")
    end

    test "revision_exists/1 returns false" do
      refute Vulnerabilities.revision_exists("0000")
    end
  end

  describe "vulnerabilities" do
    test "list_vulnerabilities/0 outputs list" do
      %{id: id} = vulnerability_fixture()

      assert [%Vulnerability{id: ^id}] =
               Vulnerabilities.transaction(fn ->
                 Vulnerabilities.list_vulnerabilities() |> Enum.to_list()
               end)
    end

    test "get_vulnerability/1 finds vulnerability" do
      %{id: id} = vulnerability_fixture()

      assert %Vulnerability{id: ^id} = Vulnerabilities.get_vulnerability(id)
    end

    test "get_vulnerability/1 returns nil" do
      assert Vulnerabilities.get_vulnerability("unknown id") == nil
    end

    test "create_vulnerability/1 works" do
      Vulnerabilities.subscribe_package()
      Vulnerabilities.subscribe_vulnerability()

      %{package_id: package_id} = vulnerability = vulnerability_fixture()

      assert_receive {:added, ^vulnerability}
      assert_receive {:added, %Package{id: ^package_id}}

      %{package_id: package_id} = vulnerability = vulnerability_fixture()

      assert_receive {:added, ^vulnerability}
      refute_receive {:added, %Package{id: ^package_id}}
    end

    test "update_vulnerability/1 works" do
      %{package_id: package_id} = vulnerability = vulnerability_fixture()

      Vulnerabilities.subscribe_package()
      Vulnerabilities.subscribe_vulnerability()

      updated_vulnerability = %{vulnerability | package_id: "xain"}

      Vulnerabilities.update_vulnerability(updated_vulnerability)

      assert_receive {:changed, ^updated_vulnerability}
      refute_receive {:added, %Package{id: ^package_id}}
      assert_receive {:added, %Package{id: "xain"}}
    end

    test "replace_vulnerability/1 works" do
      %{package_id: package_id, id: old_id} = vulnerability = vulnerability_fixture()

      Vulnerabilities.subscribe_package()
      Vulnerabilities.subscribe_vulnerability()

      updated_vulnerability = %{vulnerability | id: "new"}

      Vulnerabilities.replace_vulnerability(updated_vulnerability, old_id)

      assert_receive {:added, ^updated_vulnerability}
      refute_receive {:added, %Package{id: ^package_id}}
    end
  end
end
