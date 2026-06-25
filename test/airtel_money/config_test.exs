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
      config = %{environment: :sandbox, country: "KE"}
      assert AirtelMoney.Config.base_url(config) == "https://openapi.airtel.africa"
    end

    test "returns production URL for production environment" do
      config = %{environment: :production, country: "KE"}
      assert AirtelMoney.Config.base_url(config) == "https://openapi.airtel.africa"
    end

    test "returns DRC sandbox URL for DRC country" do
      config = %{environment: :sandbox, country: "CD"}
      assert AirtelMoney.Config.base_url(config) == "https://openapiuat.airtel.cd"
    end

    test "returns DRC production URL for DRC country" do
      config = %{environment: :production, country: "CD"}
      assert AirtelMoney.Config.base_url(config) == "https://openapi.airtel.cd"
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
        country: "KE",
        currency: "KES"
      }

      {:ok, config: config}
    end

    test "token_url/1", %{config: config} do
      assert AirtelMoney.Config.token_url(config) ==
               "https://openapi.airtel.africa/auth/oauth2/token"
    end

    test "collections_url/1 for non-DRC markets", %{config: config} do
      assert AirtelMoney.Config.collections_url(config) ==
               "https://openapi.airtel.africa/merchant/v1/payments/"
    end

    test "collections_url/1 for DRC market" do
      config = %{environment: :sandbox, country: "CD"}

      assert AirtelMoney.Config.collections_url(config) ==
               "https://openapiuat.airtel.cd/merchant/v2/payments/"
    end

    test "disbursements_url/1 for non-DRC markets", %{config: config} do
      assert AirtelMoney.Config.disbursements_url(config) ==
               "https://openapi.airtel.africa/openapi/moneytransfer/v2/credit"
    end

    test "disbursements_url/1 for DRC market" do
      config = %{environment: :sandbox, country: "CD"}

      assert AirtelMoney.Config.disbursements_url(config) ==
               "https://openapiuat.airtel.cd/standard/v2/disbursements/"
    end

    test "transaction_status_url/2 for non-DRC markets", %{config: config} do
      assert AirtelMoney.Config.transaction_status_url(config, "TXN123") ==
               "https://openapi.airtel.africa/standard/v1/payments/TXN123"
    end

    test "transaction_status_url/2 for DRC market" do
      config = %{environment: :sandbox, country: "CD"}

      assert AirtelMoney.Config.transaction_status_url(config, "TXN123") ==
               "https://openapiuat.airtel.cd/standard/v1/payments/TXN123"
    end

    test "balance_url/1 for non-DRC markets", %{config: config} do
      assert AirtelMoney.Config.balance_url(config) ==
               "https://openapi.airtel.africa/standard/v1/users/balance"
    end

    test "balance_url/1 for DRC market" do
      config = %{environment: :sandbox, country: "CD"}

      assert AirtelMoney.Config.balance_url(config) ==
               "https://openapiuat.airtel.cd/standard/v1/users/balance"
    end

    test "DRC market uses different base URL for all endpoints" do
      config = %{environment: :sandbox, country: "CD", currency: "CDF"}

      assert AirtelMoney.Config.token_url(config) ==
               "https://openapiuat.airtel.cd/auth/oauth2/token"

      assert AirtelMoney.Config.collections_url(config) ==
               "https://openapiuat.airtel.cd/merchant/v2/payments/"

      assert AirtelMoney.Config.balance_url(config) ==
               "https://openapiuat.airtel.cd/standard/v1/users/balance"
    end
  end
end
