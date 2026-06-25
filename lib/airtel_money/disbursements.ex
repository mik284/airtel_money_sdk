defmodule AirtelMoney.Disbursements do
  @moduledoc """
  Module for Airtel Money Disbursements API.

  Allows sending payments to customers.
  """

  @doc """
  Initiates a disbursement request.

  ## Parameters

  * `params` - A map with the following keys:
    * `:amount` - Amount to disburse (string)
    * `:msisdn` - Recipient phone number (string)
    * `:reference` - Transaction reference (string)
    * `:id_type` - Optional ID type (default: "MSISDN")
    * `:id_number` - Optional ID number
    * `:callback_url` - Optional callback URL

  ## Examples

      iex> params = %{amount: "5000", msisdn: "2439xxxxxxx", reference: "PAY-001"}
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
      AirtelMoney.Client.post(url, token: token, endpoint: :disbursements, config: config, body: body)
    end
  end

  defp build_disbursement_body(params, config) do
    %{
      amount: Map.get(params, :amount),
      phone: Map.get(params, :msisdn),
      external_id: Map.get(params, :reference),
      id_type: Map.get(params, :id_type, "MSISDN"),
      id_number: Map.get(params, :id_number),
      callback_url: Map.get(params, :callback_url),
      country: Map.get(config, :country),
      currency: Map.get(config, :currency)
    }
  end
end
