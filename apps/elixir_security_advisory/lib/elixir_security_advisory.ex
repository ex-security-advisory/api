defmodule ElixirSecurityAdvisory do
  @moduledoc """
  Core Domain Logic and Data Access Level
  """

  @type cve :: String.t()

  @type revision ::
          :invalid
          | %{
              newest_revision_id: String.t() | nil,
              oldest_revision_id: String.t(),
              disclosure_date: Date.t(),
              cve: nil | cve,
              link: nil | URI.t(),
              title: String.t(),
              description: nil | String.t(),
              patched_versions: [Version.Requirement.t()],
              unaffected_versions: [Version.Requirement.t()],
              revision_message: String.t()
            }
  @type vulnerability :: %{id: String.t(), package_id: String.t(), revisions: [revision]}

  @type package :: %{id: String.t(), name: String.t()}

  @callback transaction((() -> return)) :: return when return: term

  @callback revision_exists(id :: String.t()) :: boolean

  @callback list_packages :: [package()]
  @callback get_package(id :: String.t()) :: package() | nil
  @callback get_package_by_name(name :: String.t()) :: package() | nil
  @callback get_package_by_vulnerability(vulnerability :: vulnerability()) :: package() | nil

  @callback list_vulnerabilities() :: [vulnerability()]
  @callback list_vulnerabilities_by_package(package :: package) :: [vulnerability]
  @callback get_vulnerability(id :: String.t()) :: vulnerability() | nil
  @callback create_vulnerability(vulnerability :: vulnerability()) :: :ok
  @callback update_vulnerability(vulnerability :: vulnerability()) :: :ok
  @callback replace_vulnerability(
              vulnerability :: vulnerability(),
              old_id :: String.t() | [String.t()]
            ) :: :ok

  @callback subscribe_package(opts :: Keyword.t()) :: :ok | {:error, term}
  @callback subscribe_package :: :ok | {:error, term}
  @callback unsubscribe_package :: :ok | {:error, term}

  @callback subscribe_vulnerability(opts :: Keyword.t()) :: :ok | {:error, term}
  @callback subscribe_vulnerability :: :ok | {:error, term}
  @callback unsubscribe_vulnerability :: :ok | {:error, term}

  @spec patched(vulnerability :: vulnerability(), version :: Version.t()) :: boolean
  def patched(%{revisions: []}, _version), do: false
  def patched(%{revisions: [%{patched_versions: nil} | _]}, _version), do: false

  def patched(
        %{revisions: [%{patched_versions: patched_versions} | _]},
        %Version{} = version
      ) do
    Enum.any?(patched_versions, &Version.match?(version, &1))
  end

  @spec unaffected(vulnerability :: vulnerability(), version :: Version.t()) :: boolean
  def unaffected(%{revisions: []}, _version), do: false
  def unaffected(%{revisions: [%{unaffected_versions: nil} | _]}, _version), do: false

  def unaffected(
        %{revisions: [%{unaffected_versions: unaffected_versions} | _]},
        %Version{} = version
      ) do
    Enum.any?(unaffected_versions, &Version.match?(version, &1))
  end

  @spec affected_by(vulnerability :: vulnerability(), version :: Version.t()) :: boolean
  def affected_by(vulnerability, version) do
    not unaffected(vulnerability, version) and not patched(vulnerability, version)
  end
end
