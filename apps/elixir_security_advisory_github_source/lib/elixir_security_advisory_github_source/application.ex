defmodule ElixirSecurityAdvisoryGithubSource.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ElixirSecurityAdvisoryGithubSource.{ImportSupervisor, Poller}

  @env Mix.env()

  @dialyzer {:no_match, start: 2}

  def start(_type, _args) do
    # List all child processes to be supervised
    children =
      case @env do
        :test ->
          [
            {Task.Supervisor, name: ImportSupervisor}
          ]

        _ ->
          [
            {Task.Supervisor, name: ImportSupervisor},
            {Poller,
             [task_supervisor: ImportSupervisor] ++
               Application.fetch_env!(:elixir_security_advisory_github_source, Poller)}
          ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirSecurityAdvisoryGithubSource.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
