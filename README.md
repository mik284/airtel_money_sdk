# AirtelMoney

An Elixir SDK for Airtel Money APIs, providing a clean and idiomatic interface for collections, disbursements, transaction queries, and webhooks.

## Features

- **Collections** - Receive payments from customers (USSD Push)
- **Disbursements** - Send payments to customers with PIN encryption
- **Transfer Status** - Check disbursement transfer status
- **Transaction Status** - Query collection transaction status
- **Balance Queries** - Check account balance
- **OAuth Token Management** - Automatic token handling and refresh
- **PIN Encryption** - RSA encryption for disbursement PINs
- **MSISDN Validation** - Phone number format validation
- **Webhook Verification** - HMAC SHA256 signature verification
- **Telemetry** - Built-in telemetry events for monitoring
- **OTP Supervision** - Robust supervision tree for production use
- **Sandbox & Production** - Support for both environments

## Installation

Add `airtel_money` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:airtel_money, "~> 0.1.0"}
  ]
end
```

Run:

```bash
mix deps.get
```

## Configuration

Configure the SDK in your `config/config.exs`:

```elixir
config :airtel_money,
  client_id: "your_client_id",
  client_secret: "your_client_secret",
  country: "CD",
  currency: "CDF",
  environment: :sandbox,
  webhook_secret: "your_webhook_secret" # Optional, for webhook verification
```

### Configuration Options

- `:client_id` (required) - Your Airtel Money client ID
- `:client_secret` (required) - Your Airtel Money client secret
- `:country` (required) - Country code (e.g., "CD" for Democratic Republic of Congo)
- `:currency` (required) - Currency code (e.g., "CDF" for Congolese Franc)
- `:environment` (optional) - `:sandbox` or `:production` (default: `:sandbox`)
- `:host` (optional) - Custom API host (overrides default)
- `:timeout` (optional) - HTTP request timeout in milliseconds (default: 15000)
- `:pool_size` (optional) - Connection pool size (default: 10)
- `:webhook_secret` (optional) - Webhook signature secret for verification
- `:rsa_public_key` (optional) - RSA public key for PIN encryption (required for disbursements in production)

## Usage

### Start the Application

The SDK uses OTP supervision. Ensure the application is started:

```elixir
# In your application.ex
children = [
  AirtelMoney.Application
]
```

### Collect a Payment

```elixir
case AirtelMoney.collect(%{
  amount: "1000",
  msisdn: "2439xxxxxxx",
  reference: "INV-001"
}) do
  {:ok, result} ->
    IO.inspect(result)

  {:error, %AirtelMoney.Error{message: message}} ->
    IO.puts("Error: #{message}")
end
```

### Disburse a Payment

```elixir
# For production, you need to encrypt the PIN first
case AirtelMoney.Encryption.encrypt_pin("1234") do
  {:ok, encrypted_pin} ->
    case AirtelMoney.disburse(%{
      amount: "5000",
      msisdn: "2439xxxxxxx",
      reference: "PAY-001",
      pin: encrypted_pin
    }) do
      {:ok, result} ->
        IO.inspect(result)

      {:error, %AirtelMoney.Error{message: message}} ->
        IO.puts("Error: #{message}")
    end

  {:error, reason} ->
    IO.puts("PIN encryption failed: #{reason}")
end
```

### Query Transaction Status

```elixir
case AirtelMoney.transaction_status("TXN123") do
  {:ok, status} ->
    IO.inspect(status)

  {:error, %AirtelMoney.Error{message: message}} ->
    IO.puts("Error: #{message}")
end
```

### Query Balance

```elixir
case AirtelMoney.balance() do
  {:ok, balance} ->
    IO.inspect(balance)

  {:error, %AirtelMoney.Error{message: message}} ->
    IO.puts("Error: #{message}")
end
```

### Validate MSISDN

```elixir
case AirtelMoney.Utils.validate_msisdn("243900000000") do
  :ok ->
    IO.puts("Valid MSISDN")

  {:error, reason} ->
    IO.puts("Invalid MSISDN: #{reason}")
end
```

### Fetch RSA Public Key

```elixir
case AirtelMoney.Encryption.fetch_public_key() do
  {:ok, public_key} ->
    IO.puts("Public key fetched successfully")
    # Store this key in your config for future use

  {:error, error} ->
    IO.puts("Failed to fetch public key: #{error.message}")
end
```

## Webhooks

The SDK supports both authenticated and unauthenticated webhooks as per the official Airtel Money API documentation.

### Webhook Payload Format

Airtel sends transaction status updates to your callback URL with the following format:

```json
{
  "transaction": {
    "id": "BBZMiscxy",
    "message": "Paid KES 5,000 to TECHNOLOGIES LIMITED",
    "status_code": "TS",
    "airtel_money_id": "MP210603.1234.L06941"
  },
  "hash": "zITVAAGYSlzl1WkUQJn81kbpT5drH3koffT8jCkcJJA="
}
```

Status codes:
- `TS` - Transaction Success
- `TF` - Transaction Failed

### Using the Plug (Phoenix)

**With Authentication (Recommended for Production):**

```elixir
pipeline :webhooks do
  plug AirtelMoney.WebhookPlug
end

scope "/webhooks" do
  pipe_through :webhooks
  post "/airtel", WebhookController, :handle
end
```

**Without Authentication (For Testing):**

```elixir
pipeline :webhooks do
  plug AirtelMoney.WebhookPlug, require_auth: false
end

scope "/webhooks" do
  pipe_through :webhooks
  post "/airtel", WebhookController, :handle
end
```

The plug will:
- Verify the webhook signature (if `require_auth: true`)
- Parse the JSON payload
- Assign the parsed data to `conn.assigns[:airtel_webhook]`
- Return 401 if verification fails (when authentication is enabled)

### Webhook Controller Example

```elixir
defmodule MyAppWeb.WebhookController do
  use MyAppWeb, :controller

  def handle(conn, _params) do
    # The plug already verified the signature and parsed the payload
    webhook_data = conn.assigns[:airtel_webhook]
    
    case webhook_data do
      %{transaction: %{id: txn_id, status_code: status_code}} ->
        # Update your database based on transaction status
        if status_code == "TS" do
          # Transaction successful - update order, send confirmation
        end
        
        if status_code == "TF" do
          # Transaction failed - notify customer, handle retry
        end
      
      _ ->
        IO.puts("Unknown webhook format")
    end
    
    send_resp(conn, 200, "OK")
  end
end
```

### Manual Webhook Verification

```elixir
# Verify webhook signature (hash is extracted from JSON body automatically)
case AirtelMoney.verify_webhook(payload) do
  :ok ->
    # Signature is valid, process webhook
    {:ok, webhook_data} = AirtelMoney.parse_webhook(payload)
    # Handle webhook_data
    
  {:error, :invalid_signature} ->
    # Invalid signature
  {:error, :missing_hash} ->
    # Hash not found in payload
  {:error, :webhook_secret_not_configured} ->
    # Webhook secret not configured
end
```

## Telemetry

The SDK emits telemetry events for monitoring:

- `[:airtel_money, :success]` - Successful API request
- `[:airtel_money, :failure]` - Failed API request

Attach handlers to monitor events:

```elixir
:telemetry.attach(
  "airtel-money-handler",
  [:airtel_money, :success],
  &handle_event/4,
  nil
)

def handle_event([:airtel_money, event], measurements, metadata, _config) do
  IO.puts("Event: #{event}, Duration: #{measurements.duration}ms")
end
```

## Error Handling

All API functions return `{:ok, result}` or `{:error, %AirtelMoney.Error{}}`.

```elixir
%AirtelMoney.Error{
  code: "ERR001",
  message: "Invalid request",
  status: 400
}
```

## Testing

Run tests:

```bash
mix test
```

Run tests with coverage:

```bash
mix test.ci
```

## Development

### Linting

```bash
mix lint
```

### Setup

```bash
mix setup
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Documentation

Full documentation is available at [HexDocs](https://hexdocs.pm/airtel_money).
