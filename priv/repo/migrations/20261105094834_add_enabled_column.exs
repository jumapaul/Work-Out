defmodule WorkOut2.Repo.Migrations.AddEnabledColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :enabled, :boolean
      add :role, :string
    end
  end
end
