defmodule AirtelMoney.Webhooks.ParserTest do
  use ExUnit.Case
  doctest AirtelMoney.Webhooks.Parser

  alias AirtelMoney.Webhooks.Parser

  describe "parse/1" do
    test "parses valid JSON payload" do
      payload = ~s({"transaction_id":"123","status":"SUCCESS"})
      assert {:ok, parsed} = Parser.parse(payload)
      assert parsed.transaction_id == "123"
      assert parsed.status == "SUCCESS"
    end

    test "normalizes string keys to atom keys" do
      payload = ~s({"transaction_id":"123","amount":"1000"})
      assert {:ok, parsed} = Parser.parse(payload)
      assert is_map(parsed)
      assert Map.has_key?(parsed, :transaction_id)
      assert Map.has_key?(parsed, :amount)
    end

    test "parses nested objects" do
      payload = ~s({"transaction_id":"123","customer":{"name":"John"}})
      assert {:ok, parsed} = Parser.parse(payload)
      assert parsed.customer.name == "John"
    end

    test "parses arrays" do
      payload = ~s({"items":[{"id":"1"},{"id":"2"}]})
      assert {:ok, parsed} = Parser.parse(payload)
      assert length(parsed.items) == 2
      assert hd(parsed.items).id == "1"
    end

    test "returns error for invalid JSON" do
      payload = "invalid json"
      assert Parser.parse(payload) == {:error, :invalid_json}
    end

    test "returns error for empty string" do
      payload = ""
      assert Parser.parse(payload) == {:error, :invalid_json}
    end
  end
end
