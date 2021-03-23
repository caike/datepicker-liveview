defmodule DatePicker.Repo do
  use Ecto.Repo,
    otp_app: :date_picker,
    adapter: Ecto.Adapters.Postgres
end
