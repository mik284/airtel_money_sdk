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
    country = Map.get(config, :country)

    formatted_msisdn =
      AirtelMoney.Utils.format_msisdn_for_country(
        Map.get(params, :msisdn),
        country
      )

    %{
      reference: Map.get(params, :reference),
      subscriber: %{
        country: country,
        currency: Map.get(config, :currency),
        msisdn: formatted_msisdn
      },
      transaction: %{
        amount: Map.get(params, :amount),
        country: country,
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
