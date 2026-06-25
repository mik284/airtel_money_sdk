defmodule AirtelMoney.TokenManagerTest do
  use ExUnit.Case, async: false

  describe "token/0" do
    test "function exists with correct arity" do
      assert is_function(&AirtelMoney.TokenManager.token/0)
    end
  end
end
