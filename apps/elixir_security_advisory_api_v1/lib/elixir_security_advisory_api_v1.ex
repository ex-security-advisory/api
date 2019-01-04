defmodule ElixirSecurityAdvisoryApiV1 do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ElixirSecurityAdvisoryApi, :controller
      use ElixirSecurityAdvisoryApi, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ElixirSecurityAdvisoryApiV1
      use ElixirSecurityAdvisoryApi, :controller_base

      use PhoenixSwagger

      @dialyzer :no_behaviours

      alias ElixirSecurityAdvisoryApiV1.Router.Helpers, as: Routes

      defp default_pagination(%{params: params} = conn, default) do
        case Map.take(conn.params, ["first", "last"]) do
          map when map == %{} -> %{conn | params: Map.merge(params, default)}
          other -> conn
        end
      end
    end
  end

  def view do
    quote do
      use ElixirSecurityAdvisoryApi, :view_base

      use Phoenix.View,
        root: "lib/elixir_security_advisory_api_v1/templates",
        namespace: ElixirSecurityAdvisoryApiV1

      alias ElixirSecurityAdvisoryApiV1.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use ElixirSecurityAdvisoryApi, :router_base
    end
  end

  def channel do
    quote do
      use ElixirSecurityAdvisoryApi, :channel_base
    end
  end

  def schema do
    quote do
      use Absinthe.Schema
      use Absinthe.Relay.Schema, :modern
    end
  end

  def subschema do
    quote do
      use Absinthe.Schema.Notation
      use Absinthe.Relay.Schema.Notation, :modern

      alias __MODULE__.Resolver
    end
  end

  def schema_scalar do
    quote do
      use Absinthe.Schema.Notation
      use Absinthe.Relay.Schema.Notation, :modern

      alias __MODULE__.Parser
      alias __MODULE__.Serializer
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
