import Config

# Test configuration for Airtel Money SDK
config :airtel_money,
  environment: :sandbox,
  client_id: "test_client_id",
  client_secret: "test_client_secret",
  country: "CD",
  currency: "CDF"

# Print only warnings and errors during test
config :logger, level: :warning
