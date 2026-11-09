defmodule WorkOut2.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WorkOut2Web.Telemetry,
      WorkOut2.Repo,
      WorkOut2.TokenCleaner.TokenCleaner,
      {DNSCluster, query: Application.get_env(:work_out_2, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WorkOut2.PubSub},
      # Start a worker by calling: WorkOut2.Worker.start_link(arg)
      # {WorkOut2.Worker, arg},
      # Start to serve requests, typically the last entry
      WorkOut2Web.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WorkOut2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WorkOut2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
