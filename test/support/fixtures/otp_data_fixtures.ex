defmodule WorkOut2.OtpDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorkOut2.OtpData` context.
  """

  @doc """
  Generate a otp.
  """
  def otp_fixture(attrs \\ %{}) do
    {:ok, otp} =
      attrs
      |> Enum.into(%{
        otp: "some otp",
        type: "some type"
      })
      |> WorkOut2.OtpData.create_otp()

    otp
  end
end
