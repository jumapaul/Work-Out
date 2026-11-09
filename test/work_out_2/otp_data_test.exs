defmodule WorkOut2.OtpDataTest do
  use WorkOut2.DataCase

  alias WorkOut2.OtpData

  describe "otps" do
    alias WorkOut2.OtpData.Otp

    import WorkOut2.OtpDataFixtures

    @invalid_attrs %{type: nil, otp: nil}

    test "list_otps/0 returns all otps" do
      otp = otp_fixture()
      assert OtpData.list_otps() == [otp]
    end

    test "get_otp!/1 returns the otp with given id" do
      otp = otp_fixture()
      assert OtpData.get_otp!(otp.id) == otp
    end

    test "create_otp/1 with valid data creates a otp" do
      valid_attrs = %{type: "some type", otp: "some otp"}

      assert {:ok, %Otp{} = otp} = OtpData.create_otp(valid_attrs)
      assert otp.type == "some type"
      assert otp.otp == "some otp"
    end

    test "create_otp/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OtpData.create_otp(@invalid_attrs)
    end

    test "update_otp/2 with valid data updates the otp" do
      otp = otp_fixture()
      update_attrs = %{type: "some updated type", otp: "some updated otp"}

      assert {:ok, %Otp{} = otp} = OtpData.update_otp(otp, update_attrs)
      assert otp.type == "some updated type"
      assert otp.otp == "some updated otp"
    end

    test "update_otp/2 with invalid data returns error changeset" do
      otp = otp_fixture()
      assert {:error, %Ecto.Changeset{}} = OtpData.update_otp(otp, @invalid_attrs)
      assert otp == OtpData.get_otp!(otp.id)
    end

    test "delete_otp/1 deletes the otp" do
      otp = otp_fixture()
      assert {:ok, %Otp{}} = OtpData.delete_otp(otp)
      assert_raise Ecto.NoResultsError, fn -> OtpData.get_otp!(otp.id) end
    end

    test "change_otp/1 returns a otp changeset" do
      otp = otp_fixture()
      assert %Ecto.Changeset{} = OtpData.change_otp(otp)
    end
  end
end
