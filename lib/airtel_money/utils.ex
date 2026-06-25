defmodule AirtelMoney.Utils do
  @moduledoc """
  Utility functions for validation and formatting.
  """

  @doc """
  Validates MSISDN format for Airtel Money.

  ## Parameters

  * `msisdn` - Phone number string

  ## Returns

  `:ok` if valid, `{:error, reason}` if invalid

  ## Examples

      iex> AirtelMoney.Utils.validate_msisdn("243900000000")
      :ok

      iex> AirtelMoney.Utils.validate_msisdn("invalid")
      {:error, "Invalid MSISDN format"}
  """
  @spec validate_msisdn(String.t()) :: :ok | {:error, String.t()}
  def validate_msisdn(msisdn) when is_binary(msisdn) do
    # Remove any spaces or special characters
    cleaned = String.replace(msisdn, ~r/[^0-9]/, "")

    cond do
      String.length(cleaned) < 10 ->
        {:error, "MSISDN too short (minimum 10 digits)"}

      String.length(cleaned) > 15 ->
        {:error, "MSISDN too long (maximum 15 digits)"}

      not String.match?(cleaned, ~r/^\d+$/) ->
        {:error, "MSISDN must contain only digits"}

      true ->
        :ok
    end
  end

  def validate_msisdn(_), do: {:error, "MSISDN must be a string"}

  @doc """
  Formats MSISDN for Airtel Money API.

  ## Parameters

  * `msisdn` - Phone number string
  * `country` - Country code (e.g., "CD")

  ## Returns

  Formatted MSISDN string

  ## Examples

      iex> AirtelMoney.Utils.format_msisdn("243900000000", "CD")
      "243900000000"
  """
  @spec format_msisdn(String.t(), String.t()) :: String.t()
  def format_msisdn(msisdn, _country) do
    String.replace(msisdn, ~r/[^0-9]/, "")
  end
end
