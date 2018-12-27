defmodule ElixirSecurityAdvisoryApiV1.Schema.Package.Resolver do
  @moduledoc false

  @vulnerabilities Application.fetch_env!(:elixir_security_advisory, ElixirSecurityAdvisory)

  use Amnesia

  alias Absinthe.Relay.Connection

  def packages(_parent, args, _resolution) do
    Amnesia.transaction do
      @vulnerabilities.list_packages()
      |> Enum.to_list()
      |> Connection.from_list(args)
    end
  end

  def vulnerabilities(package, args, _resolution) do
    Amnesia.transaction do
      package
      |> @vulnerabilities.list_vulnerabilities_by_package
      |> filter_affected_by(args[:affects_version])
      |> Connection.from_list(args)
    end
  end

  defp filter_affected_by([], _version), do: []
  defp filter_affected_by(vulnerabilities, nil), do: vulnerabilities

  defp filter_affected_by(vulnerabilities, version) do
    Enum.filter(vulnerabilities, &ElixirSecurityAdvisory.affected_by(&1, version))
  end
end
