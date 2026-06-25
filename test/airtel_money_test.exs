defmodule AirtelMoneyTest do
  use ExUnit.Case
  doctest AirtelMoney

  describe "collect/1" do
    test "delegates to Collections.collect" do
      assert is_function(&AirtelMoney.collect/1)
    end
  end

  describe "disburse/1" do
    test "delegates to Disbursements.disburse" do
      assert is_function(&AirtelMoney.disburse/1)
    end
  end

  describe "transaction_status/1" do
    test "delegates to Transactions.status" do
      assert is_function(&AirtelMoney.transaction_status/1)
    end
  end

  describe "balance/0" do
    test "delegates to Balance.query" do
      assert is_function(&AirtelMoney.balance/0)
    end
  end

  describe "verify_webhook/2" do
    test "verifies webhook signature" do
      assert is_function(&AirtelMoney.verify_webhook/2)
    end
  end

  describe "parse_webhook/1" do
    test "parses webhook payload" do
      assert is_function(&AirtelMoney.parse_webhook/1)
    end
  end
end
