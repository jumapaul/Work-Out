defmodule WorkOut2.Repo.Migrations.CreateOtps do
  use Ecto.Migration

  def change do
    create table(:otps) do
      add :otp, :string
      add :type, :string
      add :created_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
