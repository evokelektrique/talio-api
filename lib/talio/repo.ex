defmodule Talio.Repo do
  use Ecto.Repo,
    otp_app: :talio,
    adapter: Ecto.Adapters.Postgres
end
