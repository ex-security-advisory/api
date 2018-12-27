defmodule ElixirSecurityAdvisory.Repo.Migrations.CreateVulnerabilities do
  use Ecto.Migration

  def change do
    create table(:vulnerabilities) do
      add :name, :string

      timestamps()
    end

  end
end
