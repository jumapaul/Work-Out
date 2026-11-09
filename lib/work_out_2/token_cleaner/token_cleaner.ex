defmodule WorkOut2.TokenCleaner.TokenCleaner do
  use GenServer
  require Logger
  alias WorkOut2.Tokens

  @interval :timer.minutes(2)

  def start_link(opts) do
    IO.puts("-------------->Started our token cleaner job")
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    schedule_purge()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:purge, state) do
    case Tokens.delete_all_expired_tokens() do
      {:ok, count} -> Logger.info("Purged #{count} expired tokens")
    end

    schedule_purge()
    {:noreply, state}
  end

  defp schedule_purge do
    Process.send_after(self(), :purge, @interval)
  end
end
