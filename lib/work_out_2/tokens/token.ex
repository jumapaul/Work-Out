defmodule WorkOut2.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :token, :string
    field :type, :string
    field :expires_at, :utc_datetime
    field :user_id, :integer
    field :session_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:token, :type, :expires_at, :user_id, :session_id])
    |> validate_required([:token, :type, :expires_at, :user_id, :session_id])
  end
end
