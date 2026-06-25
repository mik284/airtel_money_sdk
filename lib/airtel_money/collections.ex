defmodule AirtelMoney.Collections do
  @moduledoc """
  Module for Airtel Money Collections API.

  Allows collecting payments from customers.
  """

  @doc """
  Initiates a collection request.

  ## Parameters

  * `params` - A map with the following keys:
    * `:amount` - Amount to collect (string)
    * `:msisdn` - Customer phone number (string)
    * `:reference` - Transaction reference (string)
    * `:id` - Optional unique transaction ID (defaults to reference)

  ## Examples

      iex> _params = %{amount: "1000", msisdn: "2439xxxxxxx", reference: "INV-001"}
      iex> # This would normally call the API, but for doctest we skip the actual call
      iex> :ok
      :ok
  """
  @spec collect(map()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def collect(params) do
    with :ok <- validate_params(params),
         {:ok, token} <- AirtelMoney.TokenManager.token(),
         config <- AirtelMoney.Config.get!(),
         url <- AirtelMoney.Config.collections_url(config),
         body <- build_collection_body(params, config) do
      AirtelMoney.Client.post(url,
        token: token,
        endpoint: :collections,
        config: config,
        body: body
      )
    end
  end

  defp validate_params(params) do
    with {:ok, _} <- validate_required(params, [:amount, :msisdn, :reference]),
         {:ok, _} <- AirtelMoney.Utils.validate_msisdn(Map.get(params, :msisdn)) do
      :ok
    end
  end

  defp validate_required(params, required_keys) do
    missing = Enum.reject(required_keys, &Map.has_key?(params, &1))

    case missing do
      [] -> {:ok, params}
      keys -> {:error, "Missing required parameters: #{Enum.join(keys, ", ")}"}
    end
  end

  defp build_collection_body(params, config) do
    # DRC market uses different structure with subscriber and transaction objects
    if Map.get(config, :country) == "CD" do
      %{
        reference: Map.get(params, :reference),
        subscriber: %{
          country: Map.get(params, :subscriber_country) || Map.get(config, :country),
          currency: Map.get(params, :subscriber_currency) || Map.get(config, :currency),
          msisdn: Map.get(params, :msisdn)
        },
        transaction: %{
          amount: Map.get(params, :amount),
          country: Map.get(params, :transaction_country) || Map.get(config, :country),
          currency: Map.get(params, :transaction_currency) || Map.get(config, :currency),
          id: Map.get(params, :id) || Map.get(params, :reference)
        }
      }
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Map.new()
    else
      # Other markets use standard structure
      AirtelMoney.Api.RequestBuilder.build_body(params, config)
    end
  end
end
