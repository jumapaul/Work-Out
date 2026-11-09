defmodule WorkOut2.OtpData do
  @moduledoc """
  The OtpData context.
  """

  import Ecto.Query, warn: false
  alias WorkOut2.Repo

  alias WorkOut2.OtpData.Otp

  @doc """
  Returns the list of otps.

  ## Examples

      iex> list_otps()
      [%Otp{}, ...]

  """
  def list_otps do
    Repo.all(Otp)
  end

  @doc """
  Gets a single otp.

  Raises `Ecto.NoResultsError` if the Otp does not exist.

  ## Examples

      iex> get_otp!(123)
      %Otp{}

      iex> get_otp!(456)
      ** (Ecto.NoResultsError)

  """
  def get_otp!(id), do: Repo.get!(Otp, id)

  def verify_otp(user_id, type, code) when is_binary(code) do
    otp_data = get_valid_user_otp(user_id, type)

    case otp_data do
      %Otp{otp: stored} = otp ->
        if Plug.Crypto.secure_compare(stored, code),
          do: {:ok, otp},
          else: {:error, :invalid_code}

      nil ->
        {:error, :invalid_code}
    end
  end

  def change_otp_code(%Otp{} = otp, attrs) do
    otp
    |> Otp.change_otp_changeset(attrs)
    |> Repo.update()
  end

  def get_otp_by_user_id(user_id, type) do
    Otp
    |> where([o], o.user_id == ^user_id and o.type == ^type)
    |> limit(1)
    |> Repo.one()
  end

  def get_valid_user_otp(user_id, type) do
    now = DateTime.utc_now()

    Otp
    |> where([o], o.user_id == ^user_id and o.type == ^type and o.expires_at > ^now)
    |> order_by([o], desc: o.inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Creates a otp.

  ## Examples

      iex> create_otp(%{field: value})
      {:ok, %Otp{}}

      iex> create_otp(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_otp(attrs) do
    %Otp{}
    |> Otp.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a otp.

  ## Examples

      iex> update_otp(otp, %{field: new_value})
      {:ok, %Otp{}}

      iex> update_otp(otp, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_otp(%Otp{} = otp, attrs) do
    otp
    |> Otp.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a otp.

  ## Examples

      iex> delete_otp(otp)
      {:ok, %Otp{}}

      iex> delete_otp(otp)
      {:error, %Ecto.Changeset{}}

  """
  def delete_otp(%Otp{} = otp) do
    Repo.delete(otp)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking otp changes.

  ## Examples

      iex> change_otp(otp)
      %Ecto.Changeset{data: %Otp{}}

  """
  def change_otp(%Otp{} = otp, attrs \\ %{}) do
    Otp.changeset(otp, attrs)
  end
end
