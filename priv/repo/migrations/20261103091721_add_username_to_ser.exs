defmodule WorkOut2.Repo.Migrations.AddUsernameToSer do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
    end
  end
end
