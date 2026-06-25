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
    %__MODULE__{
      code: Map.get(body, "code") || Map.get(body, :code),
      message: Map.get(body, "message") || Map.get(body, :message) || "Unknown error",
      status: status
    }
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
