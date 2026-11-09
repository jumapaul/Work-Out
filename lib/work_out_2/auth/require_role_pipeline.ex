defmodule WorkOut2.Auth.RequireRolePipeline do
  import Plug.Conn
  alias Phoenix.Controller

  def init(opts), do: List.wrap(Keyword.fetch!(opts, :roles))

  def call(conn, roles) do
    case Guardian.Plug.current_resource(conn) do
      %{role: role} = user when is_atom(role) and not is_nil(role) ->
        IO.puts("------------>The role is: #{role}")
        IO.puts("------------>roles #{inspect(roles)}")
        if role in roles do
          assign(conn, :current_user, user)
        else
          deny_access(conn, :forbidden, "You do not have access to this resource")
        end

      _ ->
        deny_access(conn, :unauthorized, "Unauthorized")
    end
  end

  def deny_access(conn, status, message) do
    conn
    |> put_status(status)
    |> Controller.json(%{error: message})
    |> halt()
  end
end
