defmodule AirtelMoney.CollectionsTest do
  use ExUnit.Case
  doctest AirtelMoney.Collections

  describe "collect/1" do
    test "function exists with correct arity" do
      assert is_function(&AirtelMoney.Collections.collect/1)
    end
  end
end
