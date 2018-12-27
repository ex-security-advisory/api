defmodule ElixirSecurityAdvisoryApiV1.Schema do
  @moduledoc false

  use ElixirSecurityAdvisoryApiV1, :schema

  @vulnerabilities Application.fetch_env!(:elixir_security_advisory, ElixirSecurityAdvisory)

  import_types(__MODULE__.Package)
  import_types(__MODULE__.Vulnerability)
  import_types(__MODULE__.Scalar)

  node interface do
    resolve_type fn
      %{id: _, package_id: _, revisions: _}, _ ->
        :vulnerability

      %{id: _, name: _}, _ ->
        :package

      _, _ ->
        nil
    end
  end

  query do
    import_fields(:package_queries)
    import_fields(:vulnerability_queries)

    node field do
      resolve &resolve_node/2
    end
  end

  subscription do
    import_fields(:package_subscriptions)
    import_fields(:vulnerability_subscriptions)
  end

  def resolve_node(%{type: :package, id: id}, _), do: {:ok, @vulnerabilities.get_package(id)}

  def resolve_node(%{type: :vulnerability, id: id}, _),
    do: {:ok, @vulnerabilities.get_vulnerability(id)}

  def resolve_node(_, _),
    do: {:ok, nil}
end
