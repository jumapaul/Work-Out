defmodule WorkOut2.Repo do
  use Ecto.Repo,
    otp_app: :work_out_2,
    adapter: Ecto.Adapters.Postgres
end
