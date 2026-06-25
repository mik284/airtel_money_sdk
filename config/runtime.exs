import Config

# Runtime configuration for Airtel Money SDK
# This file is executed for all environments, including during releases

if config_env() == :prod do
  # Override environment from runtime variable if set
  if env = System.get_env("AIRTEL_ENVIRONMENT") do
    config :airtel_money, environment: String.to_atom(env)
  end
end
