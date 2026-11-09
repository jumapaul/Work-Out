defmodule WorkOut2Web.UserJSON do
  alias WorkOut2.Users.User

  # def users(%{users: users}) do
  #   %{data: users}
  # end

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  %{
    message: "Sample message",
    data: %{
      token: "token",
      refresh_token: "Refresh token",
      email: "abc@gmail.com"
    }
  }

  # def api_response(%{message: message, data: data}) do
  #   %{
  #     message: message,
  #     data: data()
  #   }
  # end
  def sign_in_response(%{user: user, jwt: jwt, refresh: refresh}) do
    %{data: user |> data() |> Map.put(:token, jwt) |> Map.put(:refresh_token, refresh)}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
