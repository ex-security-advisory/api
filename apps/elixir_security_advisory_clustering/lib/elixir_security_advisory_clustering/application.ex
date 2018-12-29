defmodule ElixirSecurityAdvisoryClustering.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Cluster.Supervisor,
       [
         Application.get_env(:libcluster, :topologies, []),
         [name: ElixirSecurityAdvisoryClustering.ClusterSupervisor]
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirSecurityAdvisoryClustering.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
