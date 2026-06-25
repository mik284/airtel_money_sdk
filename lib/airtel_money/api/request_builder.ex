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

  A map with the request body in the correct nested structure
  """
  @spec build_body(map(), map()) :: map()
  def build_body(params, config) do
    %{
      reference: Map.get(params, :reference),
      subscriber: %{
        country: Map.get(config, :country),
        currency: Map.get(config, :currency),
        msisdn: Map.get(params, :msisdn)
      },
      transaction: %{
        amount: Map.get(params, :amount),
        country: Map.get(config, :country),
        currency: Map.get(config, :currency),
        id: Map.get(params, :transaction_id) || generate_transaction_id()
      }
    }
  end

  defp generate_transaction_id do
    # Generate a random unique ID for transaction
    Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)
  end
end
