import Config

# Development configuration for Airtel Money SDK
config :airtel_money,
  environment: :sandbox

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
