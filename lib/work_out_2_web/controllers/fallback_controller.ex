defmodule WorkOut2Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use WorkOut2Web, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: WorkOut2Web.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Resource not found"})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Invalid email or password"})
  end

  def call(conn, {:error, :invalid_code}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid or expired code"})
  end


  def call(conn, {:error, :unverified}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Verify you email"})
  end

  def call(conn, {:error, reasons}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: reasons})
  end
end
