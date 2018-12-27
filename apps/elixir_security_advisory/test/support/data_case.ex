defmodule ElixirSecurityAdvisory.DataCase do
  @moduledoc """
  Setup Database correctly to get a new cleared DB for every test
  """

  use ExUnit.CaseTemplate

  alias ElixirSecurityAdvisory.Vulnerabilities.Database

  setup _tags do
    Database.destroy()
    Database.create!(memory: [Node.self()])

    :ok
  end
end
