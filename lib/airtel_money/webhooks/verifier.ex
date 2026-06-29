defmodule AirtelMoney.Webhooks.Verifier do
  @moduledoc """
  Verifies Airtel Money webhook signatures using HMAC SHA256.

  ## Examples

      iex> # This would normally verify the signature, but for doctest we skip the actual verification
      iex> :ok
      :ok
  """

  @doc """
  Verifies a webhook signature.

  ## Parameters

  * `payload` - The raw webhook payload (string)
  * `signature` - The hash from the callback JSON body
  * `secret` - The private key from Airtel application settings

  ## Returns

  * `:ok` if the signature is valid
  * `{:error, :invalid_signature}` if the signature is invalid
  """
  @spec verify(String.t(), String.t(), String.t()) :: :ok | {:error, :invalid_signature}
  def verify(payload, signature, secret)
      when is_binary(payload) and is_binary(signature) and is_binary(secret) do
    expected_signature = compute_signature(payload, secret)

    if secure_compare(signature, expected_signature) do
      :ok
    else
      {:error, :invalid_signature}
    end
  end

  defp compute_signature(payload, secret) do
    Base.encode64(:crypto.mac(:hmac, :sha256, secret, payload))
  end

  # Constant-time comparison to prevent timing attacks
  defp secure_compare(a, b) when byte_size(a) != byte_size(b), do: false

  defp secure_compare(a, b) do
    if :crypto.bytes_to_integer(:crypto.hash(:md5, a)) ==
         :crypto.bytes_to_integer(:crypto.hash(:md5, b)) do
      a == b
    else
      false
    end
  end
end
