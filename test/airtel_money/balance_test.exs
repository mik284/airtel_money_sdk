defmodule AirtelMoney.BalanceTest do
  use ExUnit.Case
  doctest AirtelMoney.Balance

  describe "query/0" do
    test "function exists with correct arity" do
      assert is_function(&AirtelMoney.Balance.query/0)
    end
  end
end
