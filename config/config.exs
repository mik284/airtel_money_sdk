# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.

import Config

# Airtel Money SDK Configuration
# Replace with your actual credentials
config :airtel_money,
  client_id: System.get_env("AIRTEL_CLIENT_ID") || "your_client_id",
  client_secret: System.get_env("AIRTEL_CLIENT_SECRET") || "your_client_secret",
  country: System.get_env("AIRTEL_COUNTRY") || "KE",
  currency: System.get_env("AIRTEL_CURRENCY") || "KES",
  environment: String.to_atom(System.get_env("AIRTEL_ENVIRONMENT") || "production"),
  host: System.get_env("AIRTEL_HOST") || "https://openapi.airtel.africa",
  webhook_secret: System.get_env("AIRTEL_WEBHOOK_SECRET") || "your_webhook_secret_here"

# Import environment specific config
import_config "#{config_env()}.exs"
