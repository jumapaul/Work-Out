defmodule WorkOut2.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :enabled, :boolean, default: false
    field :role, Ecto.Enum, values: [:user, :admin], default: :user

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 4)
    |> unique_constraint(:email)
    |> hash_password
  end

  def enable_changeset(user) do
    change(user, enabled: true)
  end

  def password_changeset(user, attr) do
    user
    |> cast(attr, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password, Bcrypt.hash_pwd_salt(password))
  end
end
