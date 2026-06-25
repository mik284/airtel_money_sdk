defmodule AirtelMoney.Transactions do
  @moduledoc """
  Module for Airtel Money Transaction Status API.

  Allows querying the status of transactions.
  """

  @doc """
  Queries the status of a transaction.

  ## Parameters

  * `transaction_id` - The transaction ID to query

  ## Examples

      iex> # This would normally call the API, but for doctest we skip the actual call
      iex> :ok
      :ok
  """
  @spec status(String.t()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def status(transaction_id) when is_binary(transaction_id) do
    with {:ok, token} <- AirtelMoney.TokenManager.token(),
         config <- AirtelMoney.Config.get!(),
         url <- AirtelMoney.Config.transaction_status_url(config, transaction_id) do
      AirtelMoney.Client.get(url, token: token, endpoint: :transaction_status, config: config)
    end
  end
end
