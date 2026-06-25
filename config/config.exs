# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.

import Config

# Airtel Money SDK Configuration
# Replace with your actual credentials
config :airtel_money,
  client_id: System.get_env("AIRTEL_CLIENT_ID"),
  client_secret: System.get_env("AIRTEL_CLIENT_SECRET"),
  country: System.get_env("AIRTEL_COUNTRY"),
  currency: System.get_env("AIRTEL_CURRENCY"),
  environment: System.get_env("AIRTEL_ENVIRONMENT"),
  host: System.get_env("AIRTEL_HOST")

# Import environment specific config
import_config "#{config_env()}.exs"
