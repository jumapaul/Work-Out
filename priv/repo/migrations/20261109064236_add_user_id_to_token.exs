defmodule WorkOut2.Repo.Migrations.AddUserIdToToken do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :user_id, :integer
    end
  end
end
