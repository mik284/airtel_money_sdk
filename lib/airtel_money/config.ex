defmodule AirtelMoney.Config do
  @moduledoc """
  Configuration validation using NimbleOptions.

  Validates the Airtel Money SDK configuration.
  """

  @schema [
    client_id: [
      type: :string,
      required: true,
      doc: "Airtel Money client ID"
    ],
    client_secret: [
      type: :string,
      required: true,
      doc: "Airtel Money client secret"
    ],
    country: [
      type: :string,
      required: true,
      doc: "Country code (e.g., 'CD' for Democratic Republic of Congo)"
    ],
    currency: [
      type: :string,
      required: true,
      doc: "Currency code (e.g., 'CDF' for Congolese Franc)"
    ],
    environment: [
      type: :atom,
      default: :sandbox,
      doc: "Environment - :sandbox or :production"
    ],
    host: [
      type: :string,
      doc: "Custom API host (overrides default based on environment)"
    ],
    timeout: [
      type: :pos_integer,
      default: 15_000,
      doc: "HTTP request timeout in milliseconds"
    ],
    rsa_public_key: [
      type: :string,
      doc: "RSA public key for PIN encryption (required for disbursements in production)"
    ],
    webhook_secret: [
      type: :string,
      doc: "Webhook signature secret for verification"
    ]
  ]

  @doc """
  Validates the configuration.

  ## Examples

      iex> AirtelMoney.Config.validate(client_id: "test", client_secret: "secret", country: "CD", currency: "CDF")
      {:ok, %{client_id: "test", client_secret: "secret", country: "CD", currency: "CDF", environment: :sandbox, timeout: 15000}}

      iex> AirtelMoney.Config.validate([])
      {:error, "required :client_id option not found, received options: []"}
  """
  @spec validate(keyword()) :: {:ok, map()} | {:error, String.t()}
  def validate(opts) do
    case NimbleOptions.validate(opts, @schema) do
      {:ok, validated} -> {:ok, Map.new(validated)}
      {:error, message} -> {:error, Exception.message(message)}
    end
  end

  @doc """
  Returns the current configuration from the application environment.

  Raises if configuration is invalid.
  """
  @spec get!() :: map()
  def get! do
    config = Application.get_all_env(:airtel_money)

    case validate(config) do
      {:ok, validated} ->
        validated

      {:error, message} ->
        raise ArgumentError, """
        Invalid Airtel Money configuration: #{message}

        Please configure :airtel_money in your config/config.exs:

        config :airtel_money,
          client_id: "your_client_id",
          client_secret: "your_client_secret",
          country: "CD",
          currency: "CDF",
          environment: :sandbox
        """
    end
  end

  @doc """
  Returns the API base URL based on the environment.

  For DRC market (CD), uses openapi.airtel.cd
  For other markets, uses openapi.airtel.africa
  """
  @spec base_url(map()) :: String.t()
  def base_url(%{environment: :sandbox, country: "CD"} = config) do
    Map.get(config, :host) || "https://openapiuat.airtel.cd"
  end

  def base_url(%{environment: :production, country: "CD"} = config) do
    Map.get(config, :host) || "https://openapi.airtel.cd"
  end

  def base_url(%{environment: :sandbox} = config) do
    Map.get(config, :host) || "https://openapi.airtel.africa"
  end

  def base_url(%{environment: :production} = config) do
    Map.get(config, :host) || "https://openapi.airtel.africa"
  end

  def base_url(%{host: host}) when is_binary(host) do
    host
  end

  @doc """
  Returns the OAuth token endpoint.
  """
  @spec token_url(map()) :: String.t()
  def token_url(config) do
    "#{base_url(config)}/auth/oauth2/token"
  end

  @doc """
  Returns the collections endpoint.

  For DRC market (CD), uses /merchant/v2/payments/
  For other markets, uses /merchant/v1/payments
  """
  @spec collections_url(map()) :: String.t()
  def collections_url(%{country: "CD"} = config) do
    "#{base_url(config)}/merchant/v2/payments/"
  end

  def collections_url(config) do
    "#{base_url(config)}/merchant/v1/payments/"
  end

  @doc """
  Returns the disbursements endpoint.

  For DRC market (CD), uses /standard/v2/disbursements/
  For other markets, uses /openapi/moneytransfer/v2/credit
  """
  @spec disbursements_url(map()) :: String.t()
  def disbursements_url(%{country: "CD"} = config) do
    "#{base_url(config)}/standard/v2/disbursements/"
  end

  def disbursements_url(config) do
    "#{base_url(config)}/openapi/moneytransfer/v2/credit"
  end

  @doc """
  Returns the transaction status endpoint.

  For DRC market (CD), uses /standard/v1/payments/{id}
  For other markets, uses /merchant/v1/payments/{id}
  """
  @spec transaction_status_url(map(), String.t()) :: String.t()
  def transaction_status_url(%{country: "CD"} = config, transaction_id) do
    "#{base_url(config)}/standard/v1/payments/#{transaction_id}"
  end

  def transaction_status_url(config, transaction_id) do
    "#{base_url(config)}/standard/v1/payments/#{transaction_id}"
  end

  @doc """
  Returns the balance endpoint.

  For DRC market (CD), uses /standard/v2/users/balance
  For other markets, uses /merchant/v1/balance
  """
  @spec balance_url(map()) :: String.t()
  def balance_url(%{country: "CD"} = config) do
    "#{base_url(config)}/standard/v1/users/balance"
  end

  def balance_url(config) do
    "#{base_url(config)}/standard/v1/users/balance"
  end
end
