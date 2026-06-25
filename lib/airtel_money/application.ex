defmodule AirtelMoney.Application do
  @moduledoc """
  Application module for Airtel Money SDK.

  Starts the supervision tree with the TokenManager.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AirtelMoney.TokenManager
    ]

    opts = [strategy: :one_for_one, name: AirtelMoney.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
