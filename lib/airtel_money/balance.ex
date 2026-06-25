defmodule AirtelMoney.Balance do
  @moduledoc """
  Module for Airtel Money Balance API.

  Allows querying the account balance.
  """

  @doc """
  Queries the account balance.

  ## Examples

      iex> # This would normally call the API, but for doctest we skip the actual call
      iex> :ok
      :ok
  """
  @spec query() :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def query do
    with {:ok, token} <- AirtelMoney.TokenManager.token(),
         config <- AirtelMoney.Config.get!(),
         url <- AirtelMoney.Config.balance_url(config) do
      AirtelMoney.Client.get(url, token: token, endpoint: :balance, config: config)
    end
  end
end
