defmodule AirtelMoney do
  @moduledoc """
  Airtel Money SDK for Elixir.

  Provides a clean interface for interacting with Airtel Money APIs including:
  - Collections (receiving payments)
  - Disbursements (sending payments)
  - Transaction status queries
  - Balance queries
  - Webhook verification

  ## Configuration

  Configure the SDK in your `config/config.exs`:

      config :airtel_money,
        client_id: "your_client_id",
        client_secret: "your_client_secret",
        country: "CD",
        currency: "CDF",
        environment: :sandbox

  ## Usage

  ### Collect a payment

      {:ok, result} = AirtelMoney.collect(%{
        amount: "1000",
        msisdn: "2439xxxxxxx",
        reference: "INV-001"
      })

  ### Disburse a payment

      {:ok, result} = AirtelMoney.disburse(%{
        amount: "5000",
        msisdn: "2439xxxxxxx",
        reference: "PAY-001"
      })

  ### Query transaction status

      {:ok, status} = AirtelMoney.transaction_status("TXN123")

  ### Query balance

      {:ok, balance} = AirtelMoney.balance()

  ### Verify webhook

      case AirtelMoney.verify_webhook(payload, signature) do
        :ok -> # Valid webhook
        {:error, :invalid_signature} -> # Invalid signature
      end
  """

  @doc """
  Collects a payment from a customer.

  ## Parameters

  * `params` - A map with:
    * `:amount` - Amount to collect (string)
    * `:msisdn` - Customer phone number (string)
    * `:reference` - Transaction reference (string)
    * `:id_type` - Optional ID type (default: "MSISDN")
    * `:id_number` - Optional ID number
    * `:callback_url` - Optional callback URL

  ## Returns

  * `{:ok, map()}` - Successful collection
  * `{:error, AirtelMoney.Error.t()}` - Failed collection
  """
  @spec collect(map()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  defdelegate collect(params), to: AirtelMoney.Collections, as: :collect

  @doc """
  Disburses a payment to a customer.

  ## Parameters

  * `params` - A map with:
    * `:amount` - Amount to disburse (string)
    * `:msisdn` - Recipient phone number (string)
    * `:reference` - Transaction reference (string)
    * `:id_type` - Optional ID type (default: "MSISDN")
    * `:id_number` - Optional ID number
    * `:callback_url` - Optional callback URL

  ## Returns

  * `{:ok, map()}` - Successful disbursement
  * `{:error, AirtelMoney.Error.t()}` - Failed disbursement
  """
  @spec disburse(map()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  defdelegate disburse(params), to: AirtelMoney.Disbursements, as: :disburse

  @doc """
  Queries the status of a transaction.

  ## Parameters

  * `transaction_id` - The transaction ID to query

  ## Returns

  * `{:ok, map()}` - Transaction status
  * `{:error, AirtelMoney.Error.t()}` - Failed query
  """
  @spec transaction_status(String.t()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  defdelegate transaction_status(transaction_id), to: AirtelMoney.Transactions, as: :status

  @doc """
  Queries the account balance.

  ## Returns

  * `{:ok, map()}` - Account balance
  * `{:error, AirtelMoney.Error.t()}` - Failed query
  """
  @spec balance() :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  defdelegate balance(), to: AirtelMoney.Balance, as: :query

  @doc """
  Verifies a webhook signature.

  ## Parameters

  * `payload` - The raw webhook payload (string)

  ## Returns

  * `:ok` - Valid signature
  * `{:error, :invalid_signature}` - Invalid signature
  * `{:error, :missing_hash}` - Hash not found in payload
  * `{:error, :webhook_secret_not_configured}` - Webhook secret not configured

  ## Note

  The hash is extracted from the JSON body and verified using HMAC SHA256 with Base64 encoding,
  as per the official Airtel Money API documentation.
  """
  @spec verify_webhook(String.t()) :: :ok | {:error, atom()}
  def verify_webhook(payload) do
    config = AirtelMoney.Config.get!()
    secret = Map.get(config, :webhook_secret)

    if secret do
      case AirtelMoney.Webhooks.Parser.extract_hash(payload) do
        {:ok, hash} ->
          AirtelMoney.Webhooks.Verifier.verify(payload, hash, secret)

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :webhook_secret_not_configured}
    end
  end

  @doc """
  Parses a webhook payload.

  ## Parameters

  * `payload` - The raw JSON payload (string)

  ## Returns

  * `{:ok, map()}` - Parsed payload
  * `{:error, :invalid_json}` - Invalid JSON
  """
  @spec parse_webhook(String.t()) :: {:ok, map()} | {:error, :invalid_json}
  defdelegate parse_webhook(payload), to: AirtelMoney.Webhooks.Parser, as: :parse
end
