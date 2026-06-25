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
    1. Verify the webhook signature
    2. Parse the JSON payload
    3. Assign the parsed data to `conn.assigns[:airtel_webhook]`
    4. Call the next plug if verification succeeds
    5. Return 401 if verification fails
    """

    import Plug.Conn

    @behaviour Plug

    @impl true
    def init(opts), do: opts

    @impl true
    def call(conn, _opts) do
      case get_req_header(conn, "x-airtel-signature") do
        [signature] ->
          handle_webhook(conn, signature)

        [] ->
          send_resp(conn, :unauthorized, "Missing signature")
          halt(conn)
      end
    end

    defp handle_webhook(conn, signature) do
      {:ok, body, conn} = read_body(conn)

      case AirtelMoney.verify_webhook(body, signature) do
        :ok ->
          case AirtelMoney.parse_webhook(body) do
            {:ok, webhook_data} ->
              conn
              |> assign(:airtel_webhook, webhook_data)
              |> assign(:airtel_raw_webhook, body)

            {:error, :invalid_json} ->
              send_resp(conn, :bad_request, "Invalid JSON")
              halt(conn)
          end

        {:error, :invalid_signature} ->
          send_resp(conn, :unauthorized, "Invalid signature")
          halt(conn)
      end
    end
  end
end
