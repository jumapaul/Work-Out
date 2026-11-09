defmodule WorkOut2.OtpData.Otp do
  use Ecto.Schema
  import Ecto.Changeset

  schema "otps" do
    field :otp, :string
    field :type, Ecto.Enum, values: [:verification_code, :password_reset]
    field :expires_at, :utc_datetime
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(otp, attrs) do
    otp
    |> cast(attrs, [:otp, :type, :user_id, :expires_at])
    |> validate_required([:otp, :type, :user_id, :expires_at])
  end

  def change_otp_changeset(otp, attrs) do
    otp
    |> cast(attrs, [:otp, :expires_at])
    |> validate_required([:otp, :expires_at])
  end
end
