defmodule ElixirSecurityAdvisoryGithubSource.Poller do
  @moduledoc """
  Poll if the master reference has changed
  """

  use GenServer

  alias ElixirSecurityAdvisoryGithubSource.Sync

  @server __MODULE__

  @wait_timeout 10_000
  @poll_timeout 60_000

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, @server))

  @impl GenServer
  def init(opts) do
    task_supervisor = Keyword.fetch!(opts, :task_supervisor)
    repository_config = Keyword.fetch!(opts, :repository)
    client = %Github.Client{access_token: Keyword.fetch!(opts, :access_token)}

    {:ok,
     %{task_supervisor: task_supervisor, repository_config: repository_config, client: client}, 0}
  end

  @impl GenServer
  def handle_info(
        :timeout,
        %{task_supervisor: task_supervisor, repository_config: repository_config, client: client} =
          state
      ) do
    poll(task_supervisor, repository_config, client)

    {:noreply, state, @wait_timeout}
  end

  defp poll(task_supervisor, repository_config, client) do
    task_supervisor
    |> Task.Supervisor.async_nolink(fn ->
      Sync.sync(repository_config, client)
    end)
    |> Task.await(@poll_timeout)

    :ok
  end
end
