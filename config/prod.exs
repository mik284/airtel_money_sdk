import Config

# Production configuration for Airtel Money SDK
config :airtel_money,
  environment: :production

# Do not print debug messages in production
config :logger, level: :info
