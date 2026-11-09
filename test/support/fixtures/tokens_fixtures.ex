defmodule WorkOut2.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorkOut2.Tokens` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        expires_at: ~U[2026-11-07 14:58:00Z],
        token: "some token",
        type: "some type"
      })
      |> WorkOut2.Tokens.create_token()

    token
  end
end
