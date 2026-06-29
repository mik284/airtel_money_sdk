if Code.ensure_loaded?(Plug) do
  defmodule AirtelMoney.WebhookPlug do
    @moduledoc """
    Plug for handling Airtel Money webhooks in Phoenix applications.

    ## Usage

    Add to your router:

      pipeline :webhooks do
        plug AirtelMoney.WebhookPlug
      end

      scope "/webhooks" do
        pipe_through :webhooks
        post "/airtel", WebhookController, :handle
      end

    The plug will:
    1. Verify the webhook signature (if webhook_secret is configured)
    2. Parse the JSON payload
    3. Assign the parsed data to `conn.assigns[:airtel_webhook]`
    4. Call the next plug if verification succeeds or if authentication is disabled
    5. Return 401 if verification fails (when authentication is enabled)

    ## Options

    * `:require_auth` - Set to `false` to skip signature verification (default: `true`)
    """

    import Plug.Conn

    @behaviour Plug

    @impl true
    def init(opts), do: opts

    @impl true
    def call(conn, opts) do
      require_auth = Keyword.get(opts, :require_auth, true)
      {:ok, body, conn} = read_body(conn)

      if require_auth do
        handle_authenticated_webhook(conn, body)
      else
        handle_unauthenticated_webhook(conn, body)
      end
    end

    defp handle_authenticated_webhook(conn, body) do
      config = AirtelMoney.Config.get!()
      webhook_secret = Map.get(config, :webhook_secret)

      if webhook_secret do
        with {:ok, hash} <- AirtelMoney.Webhooks.Parser.extract_hash(body),
             :ok <- AirtelMoney.Webhooks.Verifier.verify(body, hash, webhook_secret) do
          parse_and_assign(conn, body)
        else
          {:error, :missing_hash} ->
            send_resp(conn, :bad_request, "Missing hash in callback body")
            halt(conn)

          {:error, :invalid_signature} ->
            send_resp(conn, :unauthorized, "Invalid signature")
            halt(conn)
        end
      else
        send_resp(conn, :internal_server_error, "Webhook secret not configured")
        halt(conn)
      end
    end

    defp handle_unauthenticated_webhook(conn, body) do
      parse_and_assign(conn, body)
    end

    defp parse_and_assign(conn, body) do
      case AirtelMoney.parse_webhook(body) do
        {:ok, webhook_data} ->
          conn
          |> assign(:airtel_webhook, webhook_data)
          |> assign(:airtel_raw_webhook, body)

        {:error, :invalid_json} ->
          send_resp(conn, :bad_request, "Invalid JSON")
          halt(conn)
      end
    end
  end
end
