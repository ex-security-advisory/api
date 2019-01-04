defmodule ElixirSecurityAdvisoryApiV1.PackageView do
  @moduledoc false

  use JSONAPI.View, type: "packages", namespace: "/v1"

  def fields do
    [:name]
  end

  def meta(%{cursor: cursor}, _conn) do
    %{cursor: cursor}
  end

  def relationships do
    [vulnerabilities: {ElixirSecurityAdvisoryApiV1.VulnerabilityView, :include}]
  end

  def render("normalize_" <> view, %{"edges" => edges, "pageInfo" => page_info} = params) do
    params =
      params
      |> Map.put(
        :data,
        for %{"node" => node, "cursor" => cursor} <- edges do
          node
          |> IO.inspect()
          |> recursive_atom_key
          |> IO.inspect()
          |> Map.put(:cursor, cursor)
        end
      )
      |> Map.put(:meta, page_info)

    IO.inspect(render(view, params))
  end

  defp recursive_atom_key(%{} = params) do
    for {key, value} <- params, into: %{} do
      if is_binary(key) do
        try do
          {String.to_existing_atom(key), recursive_atom_key(value)}
        rescue
          Foo -> {key, recursive_atom_key(value)}
        end
      else
        {key, recursive_atom_key(value)}
      end
    end
  end

  defp recursive_atom_key(params) when is_list(params) do
    for value <- params do
      recursive_atom_key(params)
    end
  end

  defp recursive_atom_key(value) do
    value
  end
end
