defmodule AirtelMoney.Disbursements do
  @moduledoc """
  Module for Airtel Money Disbursements API.

  Allows sending payments to customers, validating payees, and checking transfer status.
  """

  @doc """
  Initiates a disbursement request.

  ## Parameters

  * `params` - A map with the following keys:
    * `:msisdn` - Recipient phone number (string, required)
    * `:amount` - Amount to disburse (string, required)
    * `:reference` - Transaction reference (string, required)
    * `:id` - Optional unique transaction ID (defaults to reference)
    * `:pin` - Optional encrypted PIN (required for production)
    * `:payee_wallet_type` - Wallet type (default: "COLL")
    * `:payee_currency` - Payee currency (default: config currency)
    * `:payee_name` - Optional payee name
    * `:transaction_type` - Transaction type (default: "B2C")
    * `:version_tag` - API version (default: "v2")

  ## Examples

      iex> _params = %{amount: "5000", msisdn: "2439xxxxxxx", reference: "PAY-001"}
      iex> # This would normally call the API, but for doctest we skip the actual call
      iex> :ok
      :ok
  """
  @spec disburse(map()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def disburse(params) do
    with {:ok, token} <- AirtelMoney.TokenManager.token(),
         config <- AirtelMoney.Config.get!(),
         url <- AirtelMoney.Config.disbursements_url(config),
         body <- build_disbursement_body(params, config) do
      AirtelMoney.Client.post(url,
        token: token,
        endpoint: :disbursements,
        config: config,
        body: body
      )
    end
  end

  defp build_disbursement_body(params, config) do
    if Map.get(config, :country) == "CD" do
      build_drc_disbursement_body(params, config)
    else
      build_standard_disbursement_body(params, config)
    end
  end

  defp build_drc_disbursement_body(params, config) do
    %{
      payee: build_payee_object(params, config),
      reference: Map.get(params, :reference),
      pin: Map.get(params, :pin),
      transaction: build_transaction_object(params)
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp build_payee_object(params, config) do
    %{
      currency: Map.get(params, :payee_currency) || Map.get(config, :currency),
      msisdn: Map.get(params, :msisdn),
      name: Map.get(params, :payee_name)
    }
  end

  defp build_transaction_object(params) do
    %{
      amount: Map.get(params, :amount),
      id: Map.get(params, :id) || Map.get(params, :reference),
      type: Map.get(params, :transaction_type, "B2B")
    }
  end

  defp build_standard_disbursement_body(params, config) do
    %{
      payee_msisdn: Map.get(params, :msisdn),
      payee_wallet_type: Map.get(params, :payee_wallet_type, "COLL"),
      payee_currency: Map.get(params, :payee_currency) || Map.get(config, :currency),
      payee_name: Map.get(params, :payee_name),
      reference: Map.get(params, :reference),
      pin: Map.get(params, :pin),
      pin_encrypted: Map.get(params, :pin_encrypted),
      amount: Map.get(params, :amount),
      transaction_id: Map.get(params, :id) || Map.get(params, :reference),
      transaction_type: Map.get(params, :transaction_type, "B2C"),
      version_tag: Map.get(params, :version_tag, "v2")
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end
end
