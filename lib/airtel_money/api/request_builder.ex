defmodule AirtelMoney.Api.RequestBuilder do
  @moduledoc """
  Helper module for building API request bodies.
  """

  @doc """
  Builds a standard request body for collections and disbursements.

  ## Parameters

  * `params` - Request parameters map
  * `config` - Configuration map

  ## Returns

  A map with the request body
  """
  @spec build_body(map(), map()) :: map()
  def build_body(params, config) do
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
