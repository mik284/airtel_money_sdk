defmodule AirtelMoney.Client do
  @moduledoc """
  HTTP client for Airtel Money API using Req.

  Handles authentication, retries, telemetry, and error handling.
  """

  require Logger

  @type request_opts :: keyword()

  @doc """
  Makes a GET request to the Airtel Money API.

  ## Options

  * `:token` - OAuth bearer token (required)
  * `:endpoint` - Endpoint name for telemetry (required)
  * `:config` - Configuration map (required)
  """
  @spec get(String.t(), request_opts()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def get(url, opts) do
    token = Keyword.fetch!(opts, :token)
    endpoint = Keyword.fetch!(opts, :endpoint)
    config = Keyword.fetch!(opts, :config)

    start_time = System.monotonic_time(:millisecond)

    req =
      Req.new(
        base_url: AirtelMoney.Config.base_url(config),
        auth: {:bearer, token},
        headers: default_headers(),
        retry: :transient,
        retry_delay: &retry_delay/1,
        max_retries: 3,
        receive_timeout: Map.get(config, :timeout, 15_000)
      )

    case Req.get(req, url: url) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:success, endpoint, duration, status)
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:failure, endpoint, duration, status)
        {:error, AirtelMoney.Error.from_response(body, status)}

      {:error, exception} ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:failure, endpoint, duration, nil)
        Logger.error("Airtel Money request failed: #{Exception.message(exception)}")
        {:error, AirtelMoney.Error.from_message(Exception.message(exception))}
    end
  end

  @doc """
  Makes a POST request to the Airtel Money API.

  ## Options

  * `:token` - OAuth bearer token (required)
  * `:endpoint` - Endpoint name for telemetry (required)
  * `:config` - Configuration map (required)
  * `:body` - Request body map (required)
  """
  @spec post(String.t(), request_opts()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def post(url, opts) do
    token = Keyword.fetch!(opts, :token)
    endpoint = Keyword.fetch!(opts, :endpoint)
    config = Keyword.fetch!(opts, :config)
    body = Keyword.fetch!(opts, :body)

    start_time = System.monotonic_time(:millisecond)

    req =
      Req.new(
        base_url: AirtelMoney.Config.base_url(config),
        auth: {:bearer, token},
        headers: default_headers(),
        retry: :transient,
        retry_delay: &retry_delay/1,
        max_retries: 3,
        receive_timeout: Map.get(config, :timeout, 15_000),
        json: body
      )

    case Req.post(req, url: url) do
      {:ok, %{status: status, body: response_body}} when status in 200..299 ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:success, endpoint, duration, status)
        {:ok, response_body}

      {:ok, %{status: status, body: response_body}} ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:failure, endpoint, duration, status)
        {:error, AirtelMoney.Error.from_response(response_body, status)}

      {:error, exception} ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:failure, endpoint, duration, nil)
        Logger.error("Airtel Money request failed: #{Exception.message(exception)}")
        {:error, AirtelMoney.Error.from_message(Exception.message(exception))}
    end
  end

  @doc """
  Makes a POST request for OAuth token (no bearer token required).
  """
  @spec post_token(String.t(), map(), map()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def post_token(url, body, config) do
    start_time = System.monotonic_time(:millisecond)

    req =
      Req.new(
        base_url: AirtelMoney.Config.base_url(config),
        headers: token_headers(),
        retry: :transient,
        retry_delay: &retry_delay/1,
        max_retries: 3,
        receive_timeout: Map.get(config, :timeout, 15_000),
        json: body
      )

    case Req.post(req, url: url) do
      {:ok, %{status: status, body: response_body}} when status in 200..299 ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:success, :token, duration, status)
        {:ok, response_body}

      {:ok, %{status: status, body: response_body}} ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:failure, :token, duration, status)
        {:error, AirtelMoney.Error.from_response(response_body, status)}

      {:error, exception} ->
        duration = System.monotonic_time(:millisecond) - start_time
        emit_telemetry(:failure, :token, duration, nil)
        Logger.error("Airtel Money token request failed: #{Exception.message(exception)}")
        {:error, AirtelMoney.Error.from_message(Exception.message(exception))}
    end
  end

  defp default_headers do
    [
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"x-country", Application.get_env(:airtel_money, :country, "")},
      {"x-currency", Application.get_env(:airtel_money, :currency, "")}
    ]
  end

  defp token_headers do
    [
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]
  end

  defp retry_delay(attempt) do
    # Exponential backoff: 100ms, 200ms, 400ms
    trunc(:math.pow(2, attempt) * 100)
  end

  defp emit_telemetry(event, endpoint, duration, status) do
    :telemetry.execute(
      [:airtel_money, event],
      %{duration: duration},
      %{endpoint: endpoint, status: status}
    )
  end
end
