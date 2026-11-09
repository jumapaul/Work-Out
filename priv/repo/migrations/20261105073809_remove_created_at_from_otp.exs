defmodule WorkOut2.Repo.Migrations.RemoveCreatedAtFromOtp do
  use Ecto.Migration

  def change do
    alter table(:otps) do
      remove :created_at, :utc_datetime
    end
  end
end
