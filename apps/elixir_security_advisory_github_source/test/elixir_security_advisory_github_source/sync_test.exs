defmodule ElixirSecurityAdvisoryGithubSource.SyncTest do
  @moduledoc false

  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import Mox

  alias ElixirSecurityAdvisoryGithubSource.Sync

  setup :verify_on_exit!

  setup do
    ExVCR.Config.filter_request_headers("Authorization")
    ExVCR.Config.cassette_library_dir("priv/test/vcr_cassettes")
    :ok
  end

  setup do
    {:ok, client: %Github.Client{access_token: System.get_env("GITHUB_ACCESS_TOKEN")}}
  end

  describe "sync/2" do
    test "does not do anything when revision exists", %{test: test, client: client} do
      use_cassette "#{__MODULE__}/#{test}" do
        expect(ElixirSecurityAdvisoryMock, :transaction, 0, fn callback ->
          callback.()
        end)

        expect(ElixirSecurityAdvisoryMock, :revision_exists, fn _revision ->
          true
        end)

        Sync.sync(
          [
            repo_path: "dependabot/elixir-security-advisories",
            path: "packages",
            branch: "master"
          ],
          client
        )
      end
    end

    test "syncs content", %{test: test, client: client} do
      agent =
        start_supervised!({Agent, fn -> %{revisions: MapSet.new(), vulnerabilities: %{}} end})

      use_cassette "#{__MODULE__}/#{test}", match_requests_on: [:query] do
        stub(ElixirSecurityAdvisoryMock, :transaction, fn callback ->
          callback.()
        end)

        stub(ElixirSecurityAdvisoryMock, :revision_exists, fn revision ->
          Agent.get(agent, fn %{revisions: revisions} ->
            MapSet.member?(revisions, revision)
          end)
        end)

        stub(ElixirSecurityAdvisoryMock, :create_vulnerability, fn %{revisions: revisions} =
                                                                     vulnerability ->
          revision_ids =
            revisions
            |> Enum.map(&[&1.newest_revision_id, &1.oldest_revision_id])
            |> List.flatten()
            |> Enum.reject(&is_nil/1)

          Agent.update(agent, fn %{vulnerabilities: vulnerabilities, revisions: old_revisions} =
                                   state ->
            %{
              state
              | vulnerabilities: Map.put_new(vulnerabilities, vulnerability.id, vulnerability),
                revisions: MapSet.union(old_revisions, MapSet.new(revision_ids))
            }
          end)
        end)

        stub(ElixirSecurityAdvisoryMock, :update_vulnerability, fn %{revisions: revisions} =
                                                                     vulnerability ->
          revision_ids =
            revisions
            |> Enum.map(&[&1.newest_revision_id, &1.oldest_revision_id])
            |> List.flatten()
            |> Enum.reject(&is_nil/1)

          Agent.update(agent, fn %{vulnerabilities: vulnerabilities, revisions: old_revisions} =
                                   state ->
            %{
              state
              | vulnerabilities: Map.put(vulnerabilities, vulnerability.id, vulnerability),
                revisions: MapSet.union(old_revisions, MapSet.new(revision_ids))
            }
          end)
        end)

        stub(ElixirSecurityAdvisoryMock, :replace_vulnerability, fn
          %{revisions: revisions} = vulnerability, old_id ->
            revision_ids =
              revisions
              |> Enum.map(&[&1.newest_revision_id, &1.oldest_revision_id])
              |> List.flatten()
              |> Enum.reject(&is_nil/1)

            Agent.update(agent, fn %{vulnerabilities: vulnerabilities, revisions: old_revisions} =
                                     state ->
              drop =
                case old_id do
                  old_ids when is_list(old_ids) -> old_ids
                  old_id when is_binary(old_id) -> [old_id]
                end

              %{
                state
                | vulnerabilities:
                    vulnerabilities
                    |> Map.put(vulnerability.id, vulnerability)
                    |> Map.drop(drop),
                  revisions: MapSet.union(old_revisions, MapSet.new(revision_ids))
              }
            end)
        end)

        stub(ElixirSecurityAdvisoryMock, :get_vulnerability, fn id ->
          Agent.get(agent, fn
            %{vulnerabilities: %{^id => vulnerability}} -> vulnerability
            _ -> nil
          end)
        end)

        Sync.sync(
          [
            repo_path: "dependabot/elixir-security-advisories",
            path: "packages",
            branch: "master"
          ],
          client
        )

        match_snapshot(Agent.get(agent, & &1), "#{__MODULE__}/#{test}")
      end
    end
  end

  defp match_snapshot(contents, name) do
    output =
      Application.app_dir(
        :elixir_security_advisory_github_source,
        "priv/test/snapshot/output/#{name}.erts"
      )

    expected_path =
      Application.app_dir(
        :elixir_security_advisory_github_source,
        "priv/test/snapshot/expected/#{name}.erts"
      )

    File.mkdir_p!(Path.dirname(output))

    File.write!(output, inspect(contents, pretty: true))

    expected =
      expected_path
      |> File.read!()
      |> String.trim(" ")
      |> String.trim("\n")
      |> String.trim("\r")

    assert expected == inspect(contents, pretty: true)
  end
end
