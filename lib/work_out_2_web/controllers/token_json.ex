defmodule WorkOut2Web.TokenJSON do
  alias WorkOut2.Tokens.Token

  @doc """
  Renders a list of tokens.
  """
  def index(%{tokens: tokens}) do
    %{data: for(token <- tokens, do: data(token))}
  end

  @doc """
  Renders a single token.
  """
  def show(%{token: token}) do
    %{data: data(token)}
  end

  defp data(%Token{} = token) do
    %{
      id: token.id,
      token: token.token,
      type: token.type,
      expires_at: token.expires_at
    }
  end
end
