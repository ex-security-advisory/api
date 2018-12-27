defmodule ElixirSecurityAdvisoryGithubSource.Sync do
  @moduledoc """
  Sync all changes into Database
  """

  @vulnerabilities Application.fetch_env!(:elixir_security_advisory, ElixirSecurityAdvisory)

  alias ElixirSecurityAdvisory.Vulnerabilities.Database.Vulnerability
  alias Github.Git.Refs
  alias Github.Repos.{Commits, Contents}

  require Logger

  def sync(repo_configuration, client) do
    %{status: 200, body: %{"object" => %{"sha" => reference}}} =
      Refs.find!(client, repo_configuration)

    unless @vulnerabilities.revision_exists(reference) do
      @vulnerabilities.transaction(fn ->
        start_import(reference, repo_configuration, client)
      end)
    end
  end

  defp start_import(reference, repo_configuration, client) do
    reference
    |> load_absent_references_and_files(repo_configuration, client)
    |> Enum.map(fn {reference, parent_reference, changed_files, revision_message} ->
      Enum.map(changed_files, &{reference, parent_reference, &1, revision_message})
    end)
    |> List.flatten()
    |> Enum.map(fn
      {reference, parent_reference, %{"status" => "removed"} = file, revision_message} ->
        {reference, parent_reference, file, nil, revision_message}

      {reference, parent_reference, %{"filename" => path} = file, revision_message} ->
        %{status: 200, body: %{"content" => content}} =
          Contents.find!(
            client,
            repo_configuration ++ [{:ref, reference}, {:path, path}]
          )

        case parse_yml(content, path) do
          %{package: package} = yml when not is_nil(package) ->
            {reference, parent_reference, file, yml, revision_message}

          _ ->
            nil
        end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.each(&import_changed_file/1)
  end

  defp load_absent_references_and_files(
         reference,
         repo_configuration,
         client,
         preceding_references \\ []
       ) do
    %{
      status: 200,
      body: %{"parents" => parents, "files" => files, "commit" => %{"message" => message}}
    } = Commits.find!(client, repo_configuration ++ [sha: reference])

    files = filter_files(files, repo_configuration)

    parent_reference =
      case parents do
        [] -> nil
        [%{"sha" => parent_reference} | _] -> parent_reference
      end

    new_references =
      case files do
        [] ->
          preceding_references

        changed_files ->
          [{reference, parent_reference, changed_files, message} | preceding_references]
      end

    case parent_reference do
      nil ->
        new_references

      parent_reference ->
        if @vulnerabilities.revision_exists(parent_reference) do
          new_references
        else
          load_absent_references_and_files(
            parent_reference,
            repo_configuration,
            client,
            new_references
          )
        end
    end
  end

  defp filter_files(files, repo_configuration) do
    base_path = Keyword.fetch!(repo_configuration, :path)

    Enum.filter(files, fn
      %{"filename" => filename} ->
        String.starts_with?(filename, base_path <> "/") and String.ends_with?(filename, ".yml")
    end)
  end

  defp import_changed_file(
         {reference, parent_reference, %{"filename" => path, "status" => "added"}, yml,
          revision_message}
       ) do
    yml
    |> new_vulnerability(path)
    |> new_vulnerability_revision(yml, reference, parent_reference, revision_message)
    |> @vulnerabilities.create_vulnerability()

    Logger.info(fn ->
      "Imported #{path} (#{reference})"
    end)
  end

  defp import_changed_file(
         {reference, parent_reference,
          %{"previous_filename" => previous_path, "filename" => path, "status" => "modified"},
          yml, revision_message}
       ) do
    Logger.warn(fn ->
      "The filename and therefore id of the vulnerability #{previous_path} changed to #{path}!"
    end)

    previous_path
    |> @vulnerabilities.get_vulnerability()
    |> case do
      nil ->
        Logger.warn(fn ->
          "The vulnerability #{previous_path} was not found, creating new one!"
        end)

        new_vulnerability(yml, path)

      %Vulnerability{} = vulnerability ->
        vulnerability
    end
    |> update_vulnerability(yml)
    |> Map.put(:id, path)
    |> new_vulnerability_revision(yml, reference, parent_reference, revision_message)
    |> @vulnerabilities.replace_vulnerability(previous_path)

    Logger.info(fn ->
      "Imported #{path} (#{reference})"
    end)
  end

  defp import_changed_file(
         {reference, parent_reference, %{"filename" => path, "status" => "modified"}, yml,
          revision_message}
       ) do
    path
    |> @vulnerabilities.get_vulnerability()
    |> case do
      nil ->
        Logger.warn(fn ->
          "The vulnerability #{path} was not found, creating new one!"
        end)

        new_vulnerability(yml, path)

      %Vulnerability{} = vulnerability ->
        vulnerability
    end
    |> update_vulnerability(yml)
    |> new_vulnerability_revision(yml, reference, parent_reference, revision_message)
    |> @vulnerabilities.update_vulnerability()

    Logger.info(fn ->
      "Imported #{path} (#{reference})"
    end)
  end

  defp import_changed_file(
         {reference, _parent_reference,
          %{"previous_filename" => previous_path, "filename" => path, "status" => "renamed"},
          _yml, _revision_message}
       ) do
    Logger.warn(fn ->
      "The filename and therefore id of the vulnerability #{previous_path} changed to #{path}!"
    end)

    previous_path
    |> @vulnerabilities.get_vulnerability()
    |> case do
      nil ->
        Logger.warn(fn ->
          "The vulnerability #{previous_path} was not found, creating new one!"
        end)

      %Vulnerability{} = vulnerability ->
        vulnerability
        |> Map.put(:id, path)
        |> @vulnerabilities.replace_vulnerability(previous_path)

        Logger.info(fn ->
          "Imported #{path} (#{reference})"
        end)
    end
  end

  defp import_changed_file(
         {_reference, _parent_reference, %{"filename" => path, "status" => "removed"}, _yml,
          _revision_message}
       ) do
    Logger.warn(fn ->
      "The file #{path} was removed. This action will not be applied!"
    end)
  end

  defp parse_yml(content, path) do
    data =
      content
      |> Base.decode64!(ignore: :whitespace)
      |> :yamerl.decode([:str_node_as_binary])
      |> List.flatten()
      |> List.flatten()
      |> Enum.reject(fn
        {_key, nil} -> true
        {_key, :null} -> true
        {_key, _value} -> false
      end)
      |> Enum.into(%{})

    %{
      package:
        if is_nil(data["package"]) do
          Logger.warn(fn ->
            "The field package of #{path} shouldn't be empty! Skipping entry!"
          end)

          nil
        else
          String.trim(data["package"])
        end,
      title:
        if is_nil(data["title"]) do
          Logger.warn(fn ->
            "The field title of #{path} shouldn't be empty!"
          end)

          nil
        else
          String.trim(data["title"])
        end,
      description:
        if is_nil(data["description"]) do
          Logger.warn(fn ->
            "The field description of #{path} shouldn't be empty!"
          end)

          nil
        else
          String.trim(data["description"])
        end,
      disclosure_date:
        if is_nil(data["disclosure_date"]) do
          Logger.warn(fn ->
            "The field disclosure_date of #{path} shouldn't be empty!"
          end)

          nil
        else
          Date.from_iso8601!(data["disclosure_date"])
        end,
      cve: data["cve"],
      link:
        unless is_nil(data["link"]) do
          URI.parse(data["link"])
        end,
      patched_versions:
        unless is_nil(data["patched_versions"]) do
          Enum.map(data["patched_versions"], fn version ->
            {:ok, req} = Version.parse_requirement(version)
            req
          end)
        end,
      unaffected_versions:
        unless is_nil(data["unaffected_versions"]) do
          Enum.map(data["unaffected_versions"], fn version ->
            {:ok, req} = Version.parse_requirement(version)
            req
          end)
        end
    }
  end

  defp new_vulnerability(%{package: package}, path) do
    %Vulnerability{
      id: path,
      package_id: package,
      revisions: []
    }
  end

  defp update_vulnerability(
         %Vulnerability{package_id: package} = vulnerability,
         %{package: package}
       ),
       do: vulnerability

  defp update_vulnerability(
         %Vulnerability{package_id: package_old} = vulnerability,
         %{package: package_new}
       ) do
    Logger.warn(fn ->
      "The vulnerability package changed from #{package_old} to #{package_new}!"
    end)

    %{vulnerability | package_id: package_new}
  end

  defp new_vulnerability_revision(
         %Vulnerability{revisions: []} = vulnerability,
         %{
           title: title,
           description: description,
           disclosure_date: disclosure_date,
           cve: cve,
           link: link,
           patched_versions: patched_versions,
           unaffected_versions: unaffected_versions
         },
         reference,
         _parent_reference,
         revision_message
       ) do
    %{
      vulnerability
      | revisions: [
          %{
            newest_revision_id: nil,
            oldest_revision_id: reference,
            title: title,
            description: description,
            disclosure_date: disclosure_date,
            cve: cve,
            link: link,
            patched_versions: patched_versions,
            unaffected_versions: unaffected_versions,
            revision_message: revision_message
          }
        ]
    }
  end

  defp new_vulnerability_revision(
         %Vulnerability{revisions: [head | tail]} = vulnerability,
         %{
           title: title,
           description: description,
           disclosure_date: disclosure_date,
           cve: cve,
           link: link,
           patched_versions: patched_versions,
           unaffected_versions: unaffected_versions
         },
         reference,
         parent_reference,
         revision_message
       ) do
    %{
      vulnerability
      | revisions: [
          %{
            newest_revision_id: nil,
            oldest_revision_id: reference,
            title: title,
            description: description,
            disclosure_date: disclosure_date,
            cve: cve,
            link: link,
            patched_versions: patched_versions,
            unaffected_versions: unaffected_versions,
            revision_message: revision_message
          },
          Map.put(head, :newest_revision_id, parent_reference)
          | tail
        ]
    }
  end
end
