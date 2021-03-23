# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :date_picker,
  ecto_repos: [DatePicker.Repo]

# Configures the endpoint
config :date_picker, DatePickerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s3lfolTJ3iz65k2WVzXhPIEXO92Hzd/12d+1MW5DqhCjduA/sztbYilRqgDmjRmX",
  render_errors: [view: DatePickerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DatePicker.PubSub,
  live_view: [signing_salt: "mkRfEfR6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
