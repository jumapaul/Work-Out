defmodule WorkOut2Web.UserController do
  use WorkOut2Web, :controller

  alias Hex.API.User
  alias WorkOut2.OtpData
  alias WorkOut2.OtpData.Otp
  alias WorkOut2.Users
  alias WorkOut2.Users.User
  alias WorkOut2.Guardian
  alias WorkOut2.EmailVerification
  alias WorkOut2.PasswordReset
  alias WorkOut2.Tokens

  action_fallback WorkOut2Web.FallbackController

  def index(conn, _params) do
    users = Users.list_users()

    render(conn, :index, users: users)
  end

  def create_user(conn, user_params) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
         code = generate_code(),
         {:ok, _otp} <-
           OtpData.create_otp(%{
             otp: to_string(code),
             type: :verification_code,
             user_id: user.id,
             expires_at: DateTime.add(DateTime.utc_now(), 30, :minute)
           }),
         email <- EmailVerification.verification_email(user, code),
         {:ok, _meta} <-
           WorkOut2.Mailer.deliver(email) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def verify_email(conn, %{"user_id" => user_id, "otp" => code}) do
    with {:ok, otp} <- OtpData.verify_otp(user_id, :verification_code, code),
         {:ok, user} <- get_user_by_id(user_id),
         {:ok, user} <- Users.enable_user(user),
         {:ok, _} <- OtpData.delete_otp(otp) do
      conn
      |> put_status(:ok)
      |> render(:show, user: user)
    end
  end

  def resend_verification_code(conn, %{"id" => user_id}) do
    with {:ok, user} <- get_user_by_id(user_id),
         {:ok, _not_enabled} <- confirm_not_enabled(user),
         %Otp{} = otp <- OtpData.get_otp_by_user_id(user_id, :verification_code),
         code = generate_code(),
         {:ok, _otp} <-
           OtpData.change_otp_code(otp, %{
             otp: to_string(code),
             expires_at: DateTime.utc_now() |> DateTime.add(30, :minute)
           }),
         email <- EmailVerification.verification_email(user, code),
         {:ok, _meta} <- WorkOut2.Mailer.deliver(email) do
      conn
      |> put_status(:ok)
      |> json(%{data: "Verification code sent to email"})
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    session_id = Ecto.UUID.generate()

    with {:ok, user} <- Users.sign_in(email, password),
         {:ok, _true} <- confirm_enabled(user),
         {:ok, token, token_claim} <-
           Guardian.encode_and_sign(user, %{sid: session_id}, token_type: "access"),
         {:ok, _token} <- save_token(token_claim),
         {:ok, refresh, refresh_claim} <-
           Guardian.encode_and_sign(user, %{sid: session_id}, token_type: "refresh"),
         {:ok, _token} <- save_token(refresh_claim) do
      render(conn, :sign_in_response, user: user, jwt: token, refresh: refresh)
    end
  end

  def send_reset_pass_code(conn, %{"id" => id}) do
    with {:ok, user} <- get_user_by_id(id),
         code = generate_code(),
         {:ok, _otp} <-
           OtpData.create_otp(%{
             otp: to_string(code),
             type: :password_reset,
             user_id: user.id,
             expires_at: DateTime.add(DateTime.utc_now(), 1, :hour)
           }),
         email <- PasswordReset.password_reset_code(user, code),
         {:ok, _meta} <- WorkOut2.Mailer.deliver(email) do
      conn
      |> put_status(:ok)
      |> json(%{data: "Reset code is sent to email"})
    end
  end

  def reset_password(conn, %{"id" => id, "otp" => code, "password" => password}) do
    with {:ok, user} <- get_user_by_id(id),
         {:ok, otp} <- OtpData.verify_otp(id, :password_reset, code),
         {:ok, _user} <- Users.reset_password(user, password),
         {:ok, _} <-
           OtpData.delete_otp(otp) do
      json(conn, %{data: "Password updated successfully"})
    end
  end

  def refresh_token(conn, _params) do
    claims = Guardian.Plug.current_claims(conn)

    with user <- Guardian.Plug.current_resource(conn),
         {:ok, access, _claims} <-
           Guardian.encode_and_sign(user, %{sid: claims["sid"]}, token_type: "access") do
      json(conn, %{token: access})
    else
      {:error, _} = error -> error
    end
  end

  def logout(conn, _params) do
    claim = Guardian.Plug.current_claims(conn)

    with {:ok, _count} <- Tokens.delete_session(claim["sid"]) do
      json(conn, %{message: "Logged out"})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp generate_code do
    :crypto.strong_rand_bytes(4)
    |> :binary.decode_unsigned()
    |> rem(900_000)
    |> Kernel.+(100_000)
  end

  defp get_user_by_id(id) do
    case Users.get_user(id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  defp save_token(claim) do
    with {:ok, token} <-
           Tokens.create_token(%{
             token: claim["jti"],
             type: claim["typ"],
             expires_at: DateTime.from_unix!(claim["exp"]),
             user_id: claim["sub"],
             session_id: claim["sid"]
           }) do
      {:ok, token}
    end
  end

  defp confirm_not_enabled(user) when user.enabled == true, do: {:error, :user_already_verified}

  defp confirm_not_enabled(user) when user.enabled == false, do: {:ok, :not_enabled}

  defp confirm_enabled(user) when user.enabled == true, do: {:ok, :enabled}

  defp confirm_enabled(user) when user.enabled == false, do: {:error, :unverified}
end
