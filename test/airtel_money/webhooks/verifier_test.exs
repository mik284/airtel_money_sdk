defmodule AirtelMoney.Webhooks.VerifierTest do
  use ExUnit.Case
  doctest AirtelMoney.Webhooks.Verifier

  alias AirtelMoney.Webhooks.Verifier

  describe "verify/3" do
    test "verifies valid signature" do
      payload = "{\"transaction_id\":\"123\"}"
      secret = "test_secret"

      signature =
        Base.encode64(:crypto.mac(:hmac, :sha256, secret, payload))

      assert Verifier.verify(payload, signature, secret) == :ok
    end

    test "rejects invalid signature" do
      payload = "{\"transaction_id\":\"123\"}"
      secret = "test_secret"
      signature = "invalid_signature"

      assert Verifier.verify(payload, signature, secret) ==
               {:error, :invalid_signature}
    end

    test "rejects signature for different payload" do
      payload1 = "{\"transaction_id\":\"123\"}"
      payload2 = "{\"transaction_id\":\"456\"}"
      secret = "test_secret"

      signature =
        Base.encode64(:crypto.mac(:hmac, :sha256, secret, payload1))

      assert Verifier.verify(payload2, signature, secret) ==
               {:error, :invalid_signature}
    end
  end
end
