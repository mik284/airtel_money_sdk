defmodule AirtelMoney.ErrorTest do
  use ExUnit.Case
  doctest AirtelMoney.Error

  describe "new/1" do
    test "creates a new error struct" do
      error = AirtelMoney.Error.new(code: "ERR001", message: "Test error", status: 400)

      assert error.code == "ERR001"
      assert error.message == "Test error"
      assert error.status == 400
    end
  end

  describe "from_response/2" do
    test "creates error from response body" do
      body = %{"code" => "ERR001", "message" => "Invalid request"}
      error = AirtelMoney.Error.from_response(body, 400)

      assert error.code == "ERR001"
      assert error.message == "Invalid request"
      assert error.status == 400
    end

    test "handles missing code in response" do
      body = %{"message" => "Invalid request"}
      error = AirtelMoney.Error.from_response(body, 400)

      assert error.code == nil
      assert error.message == "Invalid request"
      assert error.status == 400
    end

    test "handles missing message in response" do
      body = %{"code" => "ERR001"}
      error = AirtelMoney.Error.from_response(body, 400)

      assert error.code == "ERR001"
      assert error.message == "Unknown error"
      assert error.status == 400
    end
  end

  describe "from_message/1" do
    test "creates error from message" do
      error = AirtelMoney.Error.from_message("Test error")

      assert error.message == "Test error"
      assert error.code == nil
      assert error.status == nil
    end
  end

  describe "exception/1" do
    test "implements exception behaviour" do
      error = AirtelMoney.Error.exception(message: "Test error")

      assert error.message == "Test error"
    end
  end

  describe "message/1" do
    test "returns error message" do
      error = %AirtelMoney.Error{message: "Test error"}
      assert AirtelMoney.Error.message(error) == "Test error"
    end
  end
end
