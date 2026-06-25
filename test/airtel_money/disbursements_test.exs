defmodule AirtelMoney.DisbursementsTest do
  use ExUnit.Case
  doctest AirtelMoney.Disbursements

  describe "disburse/1" do
    test "function exists with correct arity" do
      assert is_function(&AirtelMoney.Disbursements.disburse/1)
    end
  end
end
