defmodule AirtelMoney.TokenManager do
  @moduledoc """
  GenServer for managing OAuth tokens.

  Automatically obtains, caches, and refreshes OAuth tokens.
  Refreshes tokens 5 minutes before expiry.
  """

  use GenServer
  require Logger

  @refresh_buffer 5 * 60 * 1000 # 5 minutes in milliseconds

  defstruct [:token, :expires_at, :config]

  @type t :: %__MODULE__{
          token: String.t() | nil,
          expires_at: integer() | nil,
          config: map() | nil
        }

  # Client API

  @doc """
  Starts the token manager.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns the current OAuth token.
  """
  @spec token() :: {:ok, String.t()} | {:error, AirtelMoney.Error.t()}
  def token do
    GenServer.call(__MODULE__, :get_token)
  end

  @doc """
  Forces a token refresh.
  """
  @spec refresh() :: :ok | {:error, AirtelMoney.Error.t()}
  def refresh do
    GenServer.call(__MODULE__, :refresh_token)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    config = AirtelMoney.Config.get!()
    # Don't auto-fetch token on startup to avoid errors with invalid credentials
    # Token will be fetched on first request
    {:ok, %__MODULE__{config: config}}
  end

  @impl true
  def handle_call(:get_token, _from, state) do
    case token_valid?(state) do
      true ->
        {:reply, {:ok, state.token}, state}

      false ->
        case fetch_token(state.config) do
          {:ok, token, expires_at} ->
            new_state = %{state | token: token, expires_at: expires_at}
            schedule_refresh(expires_at)
            {:reply, {:ok, token}, new_state}

          {:error, error} ->
            {:reply, {:error, error}, state}
        end
    end
  end

  @impl true
  def handle_call(:refresh_token, _from, state) do
    case fetch_token(state.config) do
      {:ok, token, expires_at} ->
        new_state = %{state | token: token, expires_at: expires_at}
        schedule_refresh(expires_at)
        {:reply, :ok, new_state}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  @impl true
  def handle_info(:fetch_token, state) do
    case fetch_token(state.config) do
      {:ok, token, expires_at} ->
        new_state = %{state | token: token, expires_at: expires_at}
        schedule_refresh(expires_at)
        {:noreply, new_state}

      {:error, error} ->
        Logger.error("Failed to fetch initial token: #{error.message}")
        # Retry in 30 seconds
        Process.send_after(self(), :fetch_token, 30_000)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:refresh_token, state) do
    case fetch_token(state.config) do
      {:ok, token, expires_at} ->
        new_state = %{state | token: token, expires_at: expires_at}
        schedule_refresh(expires_at)
        {:noreply, new_state}

      {:error, error} ->
        Logger.error("Failed to refresh token: #{error.message}")
        # Retry in 30 seconds
        Process.send_after(self(), :refresh_token, 30_000)
        {:noreply, state}
    end
  end

  # Private Functions

  defp token_valid?(%__MODULE__{token: nil}), do: false
  defp token_valid?(%__MODULE__{expires_at: nil}), do: false
  defp token_valid?(%__MODULE__{expires_at: expires_at}) do
    System.monotonic_time(:millisecond) < expires_at
  end

  defp fetch_token(config) do
    url = AirtelMoney.Config.token_url(config)

    body = %{
      client_id: Map.get(config, :client_id),
      client_secret: Map.get(config, :client_secret),
      grant_type: "client_credentials"
    }

    case AirtelMoney.Client.post_token(url, body, config) do
      {:ok, response} ->
        token = Map.get(response, "access_token")
        expires_in = Map.get(response, "expires_in", 3600)

        if token do
          expires_at = System.monotonic_time(:millisecond) + (expires_in * 1000)
          {:ok, token, expires_at}
        else
          {:error, AirtelMoney.Error.from_message("No access token in response")}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp schedule_refresh(expires_at) do
    refresh_time = expires_at - @refresh_buffer
    current_time = System.monotonic_time(:millisecond)
    delay = max(refresh_time - current_time, 1000)
    Process.send_after(self(), :refresh_token, delay)
  end
end
