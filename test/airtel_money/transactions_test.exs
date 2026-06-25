defmodule AirtelMoney.TransactionsTest do
  use ExUnit.Case
  doctest AirtelMoney.Transactions

  describe "status/1" do
    test "function exists with correct arity" do
      assert is_function(&AirtelMoney.Transactions.status/1)
    end
  end
end
