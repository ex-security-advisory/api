defmodule ElixirSecurityAdvisoryApiV1.Schema.Scalar.Parser do
  @moduledoc false

  def version(%Absinthe.Blueprint.Input.String{value: value}), do: Version.parse(value)
  def version(_value), do: :error
end
