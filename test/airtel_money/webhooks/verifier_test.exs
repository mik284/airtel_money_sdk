defmodule AirtelMoney.Webhooks.VerifierTest do
  use ExUnit.Case
  doctest AirtelMoney.Webhooks.Verifier

  describe "verify/3" do
    test "verifies valid signature" do
      payload = "{\"transaction_id\":\"123\"}"
      secret = "test_secret"

      signature =
        :crypto.mac(:hmac, :sha256, secret, payload)
        |> Base.encode16(case: :lower)

      assert AirtelMoney.Webhooks.Verifier.verify(payload, signature, secret) == :ok
    end

    test "rejects invalid signature" do
      payload = "{\"transaction_id\":\"123\"}"
      secret = "test_secret"
      signature = "invalid_signature"

      assert AirtelMoney.Webhooks.Verifier.verify(payload, signature, secret) ==
               {:error, :invalid_signature}
    end

    test "rejects signature for different payload" do
      payload1 = "{\"transaction_id\":\"123\"}"
      payload2 = "{\"transaction_id\":\"456\"}"
      secret = "test_secret"

      signature =
        :crypto.mac(:hmac, :sha256, secret, payload1)
        |> Base.encode16(case: :lower)

      assert AirtelMoney.Webhooks.Verifier.verify(payload2, signature, secret) ==
               {:error, :invalid_signature}
    end
  end
end
