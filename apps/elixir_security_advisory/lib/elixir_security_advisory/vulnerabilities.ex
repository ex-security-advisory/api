defmodule ElixirSecurityAdvisory.Vulnerabilities do
  @moduledoc false

  @behaviour ElixirSecurityAdvisory

  use Amnesia

  alias ElixirSecurityAdvisory.PubSub
  alias ElixirSecurityAdvisory.Vulnerabilities.Database.{Package, Revision, Vulnerability}

  @impl ElixirSecurityAdvisory
  def transaction(callback) when is_function(callback, 0) do
    Amnesia.transaction do
      callback.()
    end
  end

  @impl ElixirSecurityAdvisory
  def revision_exists(reference) when is_binary(reference) do
    Amnesia.transaction do
      reference
      |> Revision.read_at(:reference)
      |> case do
        nil -> false
        [] -> false
        [%Revision{}] -> true
      end
    end
  end

  @impl ElixirSecurityAdvisory
  def list_packages do
    Amnesia.transaction do
      Package.stream()
    end
  end

  @impl ElixirSecurityAdvisory
  def get_package(id) when is_binary(id) do
    Amnesia.transaction do
      Package.read(id)
    end
  end

  @impl ElixirSecurityAdvisory
  def get_package_by_name(name) when is_binary(name) do
    Amnesia.transaction do
      case Package.read_at(name, :name) do
        [%Package{} = package] -> package
        [] -> nil
        nil -> nil
      end
    end
  end

  defp create_package(%Package{} = package) do
    :ok =
      Amnesia.transaction do
        Package.write!(package)

        :ok
      end

    Phoenix.PubSub.broadcast(PubSub, "package", {:added, package})

    :ok
  end

  @impl ElixirSecurityAdvisory
  def list_vulnerabilities do
    Amnesia.transaction do
      Vulnerability.stream()
    end
  end

  @impl ElixirSecurityAdvisory
  def get_vulnerability(id) when is_binary(id) do
    Amnesia.transaction do
      Vulnerability.read(id)
    end
  end

  @dialyzer {:no_return, write_vulnerability: 1}
  @dialyzer {:no_fail_call, write_vulnerability: 1}

  defp write_vulnerability(
         %Vulnerability{revisions: revisions, package_id: package_id} = vulnerability
       ) do
    Amnesia.transaction do
      Vulnerability.write!(vulnerability)

      revisions_to_create =
        revisions
        |> Enum.map(&[&1.newest_revision_id, &1.oldest_revision_id])
        |> List.flatten()
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()
        |> Enum.reject(&revision_exists/1)

      case get_package(package_id) do
        nil -> create_package(%Package{id: package_id, name: package_id})
        _ -> :ok
      end

      for reference <- revisions_to_create do
        Revision.write(%Revision{reference: reference})
      end

      :ok
    end
  end

  defp write_vulnerability(%{} = vulnerability) do
    Vulnerability
    |> struct!(vulnerability)
    |> write_vulnerability()
  end

  @impl ElixirSecurityAdvisory
  def create_vulnerability(%{} = vulnerability) do
    :ok = write_vulnerability(vulnerability)

    Phoenix.PubSub.broadcast(PubSub, "vulnerability", {:added, vulnerability})
  end

  @impl ElixirSecurityAdvisory
  def update_vulnerability(%{} = vulnerability) do
    :ok = write_vulnerability(vulnerability)

    Phoenix.PubSub.broadcast(PubSub, "vulnerability", {:changed, vulnerability})
  end

  @impl ElixirSecurityAdvisory
  def replace_vulnerability(%{} = vulnerability, old_id) when is_binary(old_id) do
    Amnesia.transaction do
      create_vulnerability(vulnerability)
      Vulnerability.delete(old_id)

      :ok
    end

    Phoenix.PubSub.broadcast(PubSub, "vulnerability", {:added, vulnerability})
  end

  @impl ElixirSecurityAdvisory
  def subscribe_package(opts \\ []),
    do: Phoenix.PubSub.subscribe(PubSub, "package", opts)

  @impl ElixirSecurityAdvisory
  def unsubscribe_package,
    do: Phoenix.PubSub.unsubscribe(PubSub, "package")

  @impl ElixirSecurityAdvisory
  def subscribe_vulnerability(opts \\ []),
    do: Phoenix.PubSub.subscribe(PubSub, "vulnerability", opts)

  @impl ElixirSecurityAdvisory
  def unsubscribe_vulnerability,
    do: Phoenix.PubSub.unsubscribe(PubSub, "vulnerability")

  @impl ElixirSecurityAdvisory
  def get_package_by_vulnerability(vulnerability), do: Vulnerability.package(vulnerability)

  @impl ElixirSecurityAdvisory
  def list_vulnerabilities_by_package(package), do: Package.vulnerabilities(package)
end
