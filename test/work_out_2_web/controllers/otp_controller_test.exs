defmodule WorkOut2Web.OtpControllerTest do
  use WorkOut2Web.ConnCase

  import WorkOut2.OtpDataFixtures
  alias WorkOut2.OtpData.Otp

  @create_attrs %{
    type: "some type",
    otp: "some otp"
  }
  @update_attrs %{
    type: "some updated type",
    otp: "some updated otp"
  }
  @invalid_attrs %{type: nil, otp: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all otps", %{conn: conn} do
      conn = get(conn, ~p"/api/otps")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create otp" do
    test "renders otp when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/otps", otp: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/otps/#{id}")

      assert %{
               "id" => ^id,
               "otp" => "some otp",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/otps", otp: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update otp" do
    setup [:create_otp]

    test "renders otp when data is valid", %{conn: conn, otp: %Otp{id: id} = otp} do
      conn = put(conn, ~p"/api/otps/#{otp}", otp: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/otps/#{id}")

      assert %{
               "id" => ^id,
               "otp" => "some updated otp",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, otp: otp} do
      conn = put(conn, ~p"/api/otps/#{otp}", otp: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete otp" do
    setup [:create_otp]

    test "deletes chosen otp", %{conn: conn, otp: otp} do
      conn = delete(conn, ~p"/api/otps/#{otp}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/otps/#{otp}")
      end
    end
  end

  defp create_otp(_) do
    otp = otp_fixture()

    %{otp: otp}
  end
end
