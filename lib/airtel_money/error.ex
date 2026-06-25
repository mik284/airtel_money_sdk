defmodule AirtelMoney.Error do
  @moduledoc """
  Error struct for Airtel Money SDK errors.

  All API errors are returned as `AirtelMoney.Error` structs with
  a code, message, and HTTP status.
  """

  defexception [:code, :message, :status]

  @type t :: %__MODULE__{
          code: String.t() | nil,
          message: String.t(),
          status: integer() | nil
        }

  @drc_error_descriptions %{
    # Collection error codes (DP008000010xx)
    "DP00800001000" => "Transaction is still processing and is in ambiguous state. Please do the transaction enquiry to fetch the transaction status.",
    "DP00800001001" => "Transaction is successful.",
    "DP00800001002" => "Incorrect pin has been entered.",
    "DP00800001003" => "The User has exceeded their wallet allowed transaction limit.",
    "DP00800001004" => "The amount User is trying to transfer is less than the minimum amount allowed.",
    "DP00800001005" => "User didn't enter the pin.",
    "DP00800001006" => "Transaction in pending state. Please check after sometime.",
    "DP00800001007" => "User wallet does not have enough money to cover the payable amount.",
    "DP00800001008" => "The transaction was refused.",
    "DP00800001009" => "This is a generic refusal that has several possible causes.",
    "DP00800001010" => "Payee is already initiated for churn or barred or not registered on Airtel Money platform.",
    "DP00800001024" => "The transaction was timed out.",
    "DP00800001025" => "Transaction Not Found.",
    "DP00800001026" => "Forbidden: X-signature and payload did not match.",
    "DP00800001029" => "Transaction has been expired.",
    # Disbursement error codes (DP009000010xx)
    "DP00900001000" => "Transaction is still processing and is in ambiguous state. Please do the transaction enquiry to fetch the transaction status.",
    "DP00900001001" => "Transaction is successful.",
    "DP00900001003" => "Maximum transaction limit reached for the day.",
    "DP00900001004" => "Amount entered is out of range with respect to defined limits.",
    "DP00900001005" => "Transaction failed.",
    "DP00900001006" => "Transaction is in process.",
    "DP00900001007" => "Not enough funds in account to complete the transaction.",
    "DP00900001009" => "Initiatee of the transaction is invalid.",
    "DP00900001010" => "Payer is not an allowed user.",
    "DP00900001011" => "Transaction with similar information already exists in this system.",
    "DP00900001012" => "Mobile number entered is incorrect.",
    "DP00900001013" => "The transaction was refused.",
    "DP00900001014" => "Transaction Timed Out. The transaction may be processed or failed due to time out. To know the exact status please do the transaction enquiry.",
    "DP00900001015" => "Transaction Not Found.",
    "DP00900001016" => "Forbidden: X-signature and payload did not match.",
    "DP00900001017" => "Duplicate Transaction Id. To know the status of the actual transaction, please do transaction enquiry.",
    # Balance error codes (DP021000000xx)
    "DP02100000000" => "Balance enquiry is failed.",
    "DP02100000001" => "Balance enquiry is successful.",
    "DP02100000002" => "Invalid MSISDN provided as input."
  }

  @doc """
  Creates a new error struct.
  """
  @spec new(keyword()) :: t()
  def new(opts) do
    struct(__MODULE__, opts)
  end

  @doc """
  Creates an error from an HTTP response.
  """
  @spec from_response(map(), integer()) :: t()
  def from_response(body, status) when is_map(body) do
    code = extract_error_code(body)
    message = extract_error_message(body)

    %__MODULE__{
      code: code,
      message: format_message(message, code, status),
      status: status
    }
  end

  defp extract_error_code(body) do
    Map.get(body, "code") ||
    Map.get(body, :code) ||
    Map.get(body, "response_code") ||
    Map.get(body, "error") ||
    Map.get(body, :error)
  end

  defp extract_error_message(body) do
    Map.get(body, "message") ||
    Map.get(body, :message) ||
    Map.get(body, "status") ||
    Map.get(body, "error_description") ||
    Map.get(body, :error_description) ||
    Map.get(body, "error") ||
    Map.get(body, :error) ||
    "Unknown error"
  end

  defp format_message(message, code, status) do
    formatted_message = cond do
      is_binary(message) -> message
      is_map(message) -> Map.get(message, "description") || Map.get(message, :description) || inspect(message)
      true -> "Unknown error (code: #{inspect(code)}, status: #{status})"
    end

    add_drc_error_description(formatted_message, code)
  end

  defp add_drc_error_description(message, code) do
    description = get_drc_error_description(code)
    if description, do: "#{message} - #{description}", else: message
  end

  defp get_drc_error_description(code) do
    Map.get(@drc_error_descriptions, code)
  end

  @doc """
  Creates an error from a message.
  """
  @spec from_message(String.t()) :: t()
  def from_message(message) do
    %__MODULE__{message: message, status: nil, code: nil}
  end

  @impl true
  def exception(opts) do
    new(opts)
  end

  @impl true
  def message(%__MODULE__{message: message}) do
    message
  end
end
