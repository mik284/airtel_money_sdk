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

    req = build_request(config, auth: {:bearer, token}, headers: default_headers())
    execute_request(req, :get, url, endpoint)
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

    headers = default_headers() ++ signature_headers(config)
    req = build_request(config, auth: {:bearer, token}, headers: headers, json: body)
    execute_request(req, :post, url, endpoint)
  end

  @doc """
  Makes a POST request for OAuth token (no bearer token required).
  """
  @spec post_token(String.t(), map(), map()) :: {:ok, map()} | {:error, AirtelMoney.Error.t()}
  def post_token(url, body, config) do
    req = build_request(config, headers: token_headers(), json: body)
    execute_request(req, :post, url, :token)
  end

  defp default_headers do
    [
      {"content-type", "application/json"},
      {"accept", "*/*"},
      {"x-country", Application.get_env(:airtel_money, :country, "")},
      {"x-currency", Application.get_env(:airtel_money, :currency, "")}
    ]
  end

  defp signature_headers(config) do
    if Map.get(config, :country) == "CD" do
      signature = Application.get_env(:airtel_money, :x_signature)
      key = Application.get_env(:airtel_money, :x_key)

      []
      |> maybe_add_header("x-signature", signature)
      |> maybe_add_header("x-key", key)
    else
      []
    end
  end

  defp maybe_add_header(headers, _key, nil), do: headers
  defp maybe_add_header(headers, key, value), do: headers ++ [{key, value}]

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

  defp build_request(config, opts) do
    base_opts = [
      base_url: AirtelMoney.Config.base_url(config),
      retry: :transient,
      retry_delay: &retry_delay/1,
      max_retries: 3,
      receive_timeout: Map.get(config, :timeout, 15_000)
    ]

    Req.new(Keyword.merge(base_opts, opts))
  end

  defp execute_request(req, method, url, endpoint) do
    start_time = System.monotonic_time(:millisecond)
    response = Req.request(req, method: method, url: url)
    handle_response(response, start_time, endpoint)
  end

  defp handle_response({:ok, %{status: status, body: body}}, start_time, endpoint)
       when status in 200..299 do
    emit_telemetry_for_response(:success, endpoint, start_time, status)
    {:ok, body}
  end

  defp handle_response({:ok, %{status: status, body: body}}, start_time, endpoint) do
    emit_telemetry_for_response(:failure, endpoint, start_time, status)
    Logger.error("API request failed: status=#{status}, body=#{inspect(body)}")
    {:error, AirtelMoney.Error.from_response(body, status)}
  end

  defp handle_response({:error, exception}, start_time, endpoint) do
    emit_telemetry_for_response(:failure, endpoint, start_time, nil)
    Logger.error("Airtel Money request failed: #{Exception.message(exception)}")
    {:error, AirtelMoney.Error.from_message(Exception.message(exception))}
  end

  defp emit_telemetry_for_response(event, endpoint, start_time, status) do
    duration = System.monotonic_time(:millisecond) - start_time
    emit_telemetry(event, endpoint, duration, status)
  end
end
