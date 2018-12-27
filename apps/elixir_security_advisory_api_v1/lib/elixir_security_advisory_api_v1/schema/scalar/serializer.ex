defmodule ElixirSecurityAdvisoryApiV1.Schema.Scalar.Serializer do
  @moduledoc false

  defdelegate date(date), to: Date, as: :to_iso8601

  defdelegate version_requirement(version_requirement), to: Kernel, as: :to_string

  def markdown(markdown), do: markdown

  defdelegate uri(uri), to: URI, as: :to_string
end
