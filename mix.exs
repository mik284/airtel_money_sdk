defmodule AirtelMoney.MixProject do
  use Mix.Project

  def project do
    [
      app: :airtel_money,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  def application do
    [
      mod: {AirtelMoney.Application, []},
      extra_applications: [:logger, :crypto]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:nimble_options, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.2"},
      {:plug, "~> 1.16", optional: true},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      name: "airtel_money",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mik284/airtel_money_sdk"},
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end

  defp description do
    "Elixir SDK for Airtel Money APIs - Collections, Disbursements, and more"
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      groups_for_modules: [
        Core: ~r/AirtelMoney\.(Error|Config|Client|TokenManager)/,
        APIs: ~r/AirtelMoney\.(Collections|Disbursements|Transactions|Balance)/,
        Webhooks: ~r/AirtelMoney\.Webhooks/
      ]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "format", "credo --strict"],
      "test.ci": ["test --cover"],
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end
end
