defmodule ElixirSecurityAdvisoryApiV1.Serializer.ETS do
  @moduledoc false

  def encode!(term, _opts) do
    :erlang.term_to_binary(term)
  end
end
