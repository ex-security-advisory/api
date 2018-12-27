defmodule ElixirSecurityAdvisoryApiV1.Schema.Package do
  @moduledoc false

  use ElixirSecurityAdvisoryApiV1, :subschema

  object :package_queries do
    connection field(:packages, node_type: :package) do
      resolve(&Resolver.packages/3)
    end
  end

  object :package_subscriptions do
    field :package_added, :package do
      config fn _, _ -> {:ok, topic: :*} end
    end
  end

  connection(node_type: :package)

  node object(:package) do
    field :name, non_null(:string)

    connection field(:vulnerabilities, node_type: :vulnerability) do
      arg :affects_version, :version
      resolve(&Resolver.vulnerabilities/3)
    end
  end
end
