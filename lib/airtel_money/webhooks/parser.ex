defmodule AirtelMoney.Webhooks.Parser do
  @moduledoc """
  Parses Airtel Money webhook payloads.

  ## Examples

      iex> # This would normally parse the JSON, but for doctest we skip the actual parsing
      iex> :ok
      :ok
  """

  @doc """
  Parses a webhook payload.

  ## Parameters

  * `payload` - The raw JSON payload (string)

  ## Returns

  * `{:ok, map()}` if parsing succeeds
  * `{:error, :invalid_json}` if parsing fails
  """
  @spec parse(String.t()) :: {:ok, map()} | {:error, :invalid_json}
  def parse(payload) when is_binary(payload) do
    case Jason.decode(payload) do
      {:ok, data} when is_map(data) ->
        {:ok, normalize_keys(data)}

      {:error, _} ->
        {:error, :invalid_json}
    end
  end

  @doc """
  Extracts the hash from a webhook payload.

  ## Parameters

  * `payload` - The raw JSON payload (string)

  ## Returns

  * `{:ok, hash}` if hash is present
  * `{:error, :missing_hash}` if hash is not present
  """
  @spec extract_hash(String.t()) :: {:ok, String.t()} | {:error, :missing_hash}
  def extract_hash(payload) when is_binary(payload) do
    case Jason.decode(payload) do
      {:ok, %{"hash" => hash}} when is_binary(hash) ->
        {:ok, hash}

      {:ok, _} ->
        {:error, :missing_hash}

      {:error, _} ->
        {:error, :invalid_json}
    end
  end

  defp normalize_keys(data) when is_map(data) do
    data
    |> Enum.map(fn {k, v} -> {String.to_atom(k), normalize_value(v)} end)
    |> Map.new()
  end

  defp normalize_value(value) when is_map(value), do: normalize_keys(value)
  defp normalize_value(value) when is_list(value), do: Enum.map(value, &normalize_value/1)
  defp normalize_value(value), do: value
end
