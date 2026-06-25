defmodule AirtelMoney.Encryption do
  @moduledoc """
  Encryption module for Airtel Money disbursement PIN encryption.

  Uses RSA public key encryption for PIN protection as required by Airtel Money API.
  """

  require Logger

  @doc """
  Encrypts a PIN using RSA encryption with Airtel's public key.

  ## Parameters

  * `pin` - The PIN to encrypt (string)
  * `public_key` - Airtel's RSA public key (optional, will use config if not provided)

  ## Returns

  `{:ok, encrypted_pin}` on success, `{:error, reason}` on failure

  ## Examples

      iex> AirtelMoney.Encryption.encrypt_pin("1234")
      {:ok, "encrypted_base64_string"}
  """
  @spec encrypt_pin(String.t(), String.t() | nil) :: {:ok, String.t()} | {:error, String.t()}
  def encrypt_pin(pin, public_key \\ nil) do
    public_key = public_key || get_public_key()

    cond do
      is_nil(public_key) ->
        {:error, "RSA public key not configured. Set :airtel_money, :rsa_public_key in config"}

      is_nil(pin) or pin == "" ->
        {:error, "PIN cannot be empty"}

      true ->
        do_encrypt(pin, public_key)
    end
  end

  @doc """
  Fetches Airtel's RSA public key from the API.

  ## Returns

  `{:ok, public_key}` on success, `{:error, reason}` on failure
  """
  @spec fetch_public_key() :: {:ok, String.t()} | {:error, AirtelMoney.Error.t()}
  def fetch_public_key do
    with {:ok, token} <- AirtelMoney.TokenManager.token(),
         config <- AirtelMoney.Config.get!(),
         url <- "#{AirtelMoney.Config.base_url(config)}/v1/rsa/encryption-keys",
         {:ok, response} <- AirtelMoney.Client.get(url, token: token, endpoint: :rsa_keys, config: config) do
      extract_public_key(response)
    end
  end

  defp extract_public_key(response) do
    case Map.get(response, "public_key") do
      nil -> {:error, AirtelMoney.Error.from_message("No public key in response")}
      key -> {:ok, key}
    end
  end

  # Private functions

  defp get_public_key do
    Application.get_env(:airtel_money, :rsa_public_key)
  end

  defp do_encrypt(pin, public_key) do
    # Decode the public key from PEM format
    key_entry = :public_key.pem_decode(public_key)

    case key_entry do
      [{:RSAPublicKey, key_der, :not_encrypted}] ->
        try do
          # Encrypt the PIN using RSA
          pin_bytes = :public_key.encrypt_public(pin, {:RSAPublicKey, key_der})
          # Encode to base64
          encrypted = Base.encode64(pin_bytes)
          {:ok, encrypted}
        rescue
          e ->
            Logger.error("PIN encryption failed: #{Exception.message(e)}")
            {:error, "Failed to encrypt PIN: #{Exception.message(e)}"}
        end

      _ ->
        {:error, "Invalid RSA public key format"}
    end
  end
end
