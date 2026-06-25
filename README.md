# AirtelMoney

An Elixir SDK for Airtel Money APIs, providing a clean and idiomatic interface for collections, disbursements, transaction queries, and webhooks.

## Features

- **Collections** - Receive payments from customers
- **Disbursements** - Send payments to customers
- **Transaction Status** - Query transaction status
- **Balance Queries** - Check account balance
- **OAuth Token Management** - Automatic token handling and refresh
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
case AirtelMoney.disburse(%{
  amount: "5000",
  msisdn: "2439xxxxxxx",
  reference: "PAY-001"
}) do
  {:ok, result} ->
    IO.inspect(result)

  {:error, %AirtelMoney.Error{message: message}} ->
    IO.puts("Error: #{message}")
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

## Webhooks

### Verify Webhook Signature

```elixir
# In your webhook controller
def handle(conn, params) do
  signature = get_req_header(conn, "x-airtel-signature")
  payload = conn.assigns[:raw_body]

  case AirtelMoney.verify_webhook(payload, signature) do
    :ok ->
      # Signature is valid, process webhook
      {:ok, webhook_data} = AirtelMoney.parse_webhook(payload)
      # Handle webhook_data
      send_resp(conn, 200, "OK")

    {:error, :invalid_signature} ->
      send_resp(conn, 401, "Invalid signature")
  end
end
```

### Using the Plug (Phoenix)

Add the plug to your router:

```elixir
pipeline :webhooks do
  plug AirtelMoney.WebhookPlug
end

scope "/webhooks" do
  pipe_through :webhooks
  post "/airtel", WebhookController, :handle
end
```

The plug will:
- Verify the webhook signature
- Parse the JSON payload
- Assign the parsed data to `conn.assigns[:airtel_webhook]`
- Return 401 if verification fails

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
