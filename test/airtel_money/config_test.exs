defmodule AirtelMoney.ConfigTest do
  use ExUnit.Case
  doctest AirtelMoney.Config

  describe "validate/1" do
    test "validates valid configuration" do
      config = [
        client_id: "test_id",
        client_secret: "test_secret",
        country: "CD",
        currency: "CDF"
      ]

      assert {:ok, validated} = AirtelMoney.Config.validate(config)
      assert validated.client_id == "test_id"
      assert validated.client_secret == "test_secret"
      assert validated.country == "CD"
      assert validated.currency == "CDF"
      assert validated.environment == :sandbox
    end

    test "validates with custom environment" do
      config = [
        client_id: "test_id",
        client_secret: "test_secret",
        country: "CD",
        currency: "CDF",
        environment: :production
      ]

      assert {:ok, validated} = AirtelMoney.Config.validate(config)
      assert validated.environment == :production
    end

    test "returns error for missing required fields" do
      config = []

      assert {:error, message} = AirtelMoney.Config.validate(config)
      assert message =~ "required :client_id option not found"
    end
  end

  describe "base_url/1" do
    test "returns sandbox URL for sandbox environment" do
      config = %{environment: :sandbox}
      assert AirtelMoney.Config.base_url(config) == "https://openapi.airtel.africa"
    end

    test "returns production URL for production environment" do
      config = %{environment: :production}
      assert AirtelMoney.Config.base_url(config) == "https://openapi.airtel.africa"
    end

    test "returns custom host when provided" do
      config = %{environment: :sandbox, host: "https://custom.api.com"}
      assert AirtelMoney.Config.base_url(config) == "https://custom.api.com"
    end
  end

  describe "endpoint URLs" do
    setup do
      config = %{
        environment: :sandbox,
        country: "CD",
        currency: "CDF"
      }

      {:ok, config: config}
    end

    test "token_url/1", %{config: config} do
      assert AirtelMoney.Config.token_url(config) == "https://openapi.airtel.africa/auth/oauth2/token"
    end

    test "collections_url/1", %{config: config} do
      assert AirtelMoney.Config.collections_url(config) == "https://openapi.airtel.africa/merchant/v1/payments"
    end

    test "disbursements_url/1", %{config: config} do
      assert AirtelMoney.Config.disbursements_url(config) == "https://openapi.airtel.africa/merchant/v1/disbursements"
    end

    test "transaction_status_url/2", %{config: config} do
      assert AirtelMoney.Config.transaction_status_url(config, "TXN123") ==
               "https://openapi.airtel.africa/merchant/v1/payments/TXN123"
    end

    test "balance_url/1", %{config: config} do
      assert AirtelMoney.Config.balance_url(config) == "https://openapi.airtel.africa/merchant/v1/balance"
    end
  end
end
