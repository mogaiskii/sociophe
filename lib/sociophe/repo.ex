defmodule Sociophe.Repo do
  use Ecto.Repo,
    otp_app: :sociophe,
    adapter: Ecto.Adapters.Postgres
end
