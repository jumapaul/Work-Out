defmodule WorkOut2.Guardian do
  use Guardian, otp_app: :work_out_2

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}

  def subject_for_token(_, _), do: {:error, :add_token}

  def build_claims(claims, %{role: role}, _opts) do
    {:ok, Map.put(claims, "role", role)}
  end

  def build_claims(claims, _resource, _opts), do: {:ok, claims}

  def resource_from_claims(%{"sub" => id}) do
    case WorkOut2.Users.get_user!(id) do
      nil -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  def on_verify(claims, _token, _options) do
    if WorkOut2.Tokens.is_active?(claims["jti"]) do
      {:ok, claims}
    else
      {:error, :unauthorized}
    end
  end
end
