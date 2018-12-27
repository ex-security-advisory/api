defmodule ElixirSecurityAdvisory.Application do
  @moduledoc false

  use Application

  # alias ElixirSecurityAdvisory.Vulnerabilities.Database

  def start(_type, _args) do
    # try do
    #   # memory: [Node.self() | Node.list()]
    #   # Database.create!()
    # catch
    #   Amnesia.TableExistsError -> :ok
    # end

    # Database.wait(15_000)

    Supervisor.start_link(
      [{Phoenix.PubSub.PG2, name: ElixirSecurityAdvisory.PubSub}],
      strategy: :one_for_one,
      name: ElixirSecurityAdvisory.Supervisor
    )
  end
end
