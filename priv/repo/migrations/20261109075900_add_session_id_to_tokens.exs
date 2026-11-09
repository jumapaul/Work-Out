defmodule WorkOut2.Repo.Migrations.AddSessionIdToTokens do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :session_id, :string
    end
  end
end
