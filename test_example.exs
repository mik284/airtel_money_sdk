# Example script to test Airtel Money SDK
# Run with: mix run test_example.exs

# Start the application
Application.ensure_all_started(:airtel_money)

IO.puts("Testing Airtel Money SDK Collections API")
IO.puts("=========================================")

# Test collection request
params = %{
  amount: "1000",
  # Kenyan phone number
  msisdn: "254712345678",
  reference: "TEST-001"
}

IO.puts("\nAttempting collection with params:")
IO.inspect(params)

case AirtelMoney.Collections.collect(params) do
  {:ok, response} ->
    IO.puts("\n✓ Collection successful!")
    IO.inspect(response)

  {:error, error} ->
    IO.puts("\n✗ Collection failed:")
    IO.inspect(error)
end

# Test transaction status
IO.puts("\n\nTesting Transaction Status API")
IO.puts("================================")

case AirtelMoney.Transactions.status("TEST-TXN-ID") do
  {:ok, response} ->
    IO.puts("\n✓ Transaction status retrieved!")
    IO.inspect(response)

  {:error, error} ->
    IO.puts("\n✗ Transaction status failed:")
    IO.inspect(error)
end

# Test balance query
IO.puts("\n\nTesting Balance API")
IO.puts("====================")

case AirtelMoney.Balance.query() do
  {:ok, response} ->
    IO.puts("\n✓ Balance retrieved!")
    IO.inspect(response)

  {:error, error} ->
    IO.puts("\n✗ Balance query failed:")
    IO.inspect(error)
end

IO.puts("\n\nTest completed!")
