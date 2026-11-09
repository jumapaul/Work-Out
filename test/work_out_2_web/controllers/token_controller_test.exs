defmodule WorkOut2Web.TokenControllerTest do
  use WorkOut2Web.ConnCase

  import WorkOut2.TokensFixtures
  alias WorkOut2.Tokens.Token

  @create_attrs %{
    type: "some type",
    token: "some token",
    expires_at: ~U[2026-11-07 14:58:00Z]
  }
  @update_attrs %{
    type: "some updated type",
    token: "some updated token",
    expires_at: ~U[2026-11-08 14:58:00Z]
  }
  @invalid_attrs %{type: nil, token: nil, expires_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tokens", %{conn: conn} do
      conn = get(conn, ~p"/api/tokens")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create token" do
    test "renders token when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/tokens", token: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/tokens/#{id}")

      assert %{
               "id" => ^id,
               "expires_at" => "2026-11-07T14:58:00Z",
               "token" => "some token",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/tokens", token: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update token" do
    setup [:create_token]

    test "renders token when data is valid", %{conn: conn, token: %Token{id: id} = token} do
      conn = put(conn, ~p"/api/tokens/#{token}", token: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/tokens/#{id}")

      assert %{
               "id" => ^id,
               "expires_at" => "2026-11-08T14:58:00Z",
               "token" => "some updated token",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, token: token} do
      conn = put(conn, ~p"/api/tokens/#{token}", token: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete token" do
    setup [:create_token]

    test "deletes chosen token", %{conn: conn, token: token} do
      conn = delete(conn, ~p"/api/tokens/#{token}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/tokens/#{token}")
      end
    end
  end

  defp create_token(_) do
    token = token_fixture()

    %{token: token}
  end
end
