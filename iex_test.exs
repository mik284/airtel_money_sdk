# IEx test script for Airtel Money SDK
# Run with: iex -S mix
# Then in IEx: c("iex_test.exs")

IO.puts("Airtel Money SDK IEx Test")
IO.puts("==========================")

# Test configuration validation
IO.puts("\n1. Testing configuration validation...")

config = [
  client_id: "test_id",
  client_secret: "test_secret",
  country: "KE",
  currency: "KES"
]

case AirtelMoney.Config.validate(config) do
  {:ok, validated} ->
    IO.puts("✓ Configuration validated successfully")
    IO.inspect(validated)

  {:error, error} ->
    IO.puts("✗ Configuration validation failed: #{error}")
end

# Test base URL generation
IO.puts("\n2. Testing base URL generation...")
sandbox_config = %{environment: :sandbox}
prod_config = %{environment: :production}
custom_config = %{host: "https://custom.api.com"}

IO.puts("Sandbox URL: #{AirtelMoney.Config.base_url(sandbox_config)}")
IO.puts("Production URL: #{AirtelMoney.Config.base_url(prod_config)}")
IO.puts("Custom URL: #{AirtelMoney.Config.base_url(custom_config)}")

# Test endpoint URL generation
IO.puts("\n3. Testing endpoint URL generation...")
test_config = %{environment: :sandbox}
IO.puts("Token URL: #{AirtelMoney.Config.token_url(test_config)}")
IO.puts("Collections URL: #{AirtelMoney.Config.collections_url(test_config)}")
IO.puts("Disbursements URL: #{AirtelMoney.Config.disbursements_url(test_config)}")
IO.puts("Balance URL: #{AirtelMoney.Config.balance_url(test_config)}")

IO.puts(
  "Transaction Status URL: #{AirtelMoney.Config.transaction_status_url(test_config, "TXN123")}"
)

# Test webhook parsing
IO.puts("\n4. Testing webhook parsing...")
webhook_payload = ~s({"transaction_id":"123","status":"SUCCESS"})

case AirtelMoney.Webhooks.Parser.parse(webhook_payload) do
  {:ok, parsed} ->
    IO.puts("✓ Webhook parsed successfully")
    IO.inspect(parsed)

  {:error, error} ->
    IO.puts("✗ Webhook parsing failed: #{error}")
end

# Test function existence
IO.puts("\n5. Testing function existence...")
IO.puts("Collections.collect/1: #{is_function(&AirtelMoney.Collections.collect/1)}")
IO.puts("Disbursements.disburse/1: #{is_function(&AirtelMoney.Disbursements.disburse/1)}")
IO.puts("Transactions.status/1: #{is_function(&AirtelMoney.Transactions.status/1)}")
IO.puts("Balance.query/0: #{is_function(&AirtelMoney.Balance.query/0)}")
IO.puts("TokenManager.token/0: #{is_function(&AirtelMoney.TokenManager.token/0)}")

IO.puts("\n✓ All basic tests completed!")
IO.puts("\nNote: API calls will fail with test credentials.")
IO.puts("To test with real API, update config/config.exs with valid credentials.")
