defmodule Rendezvous.MixProject do
  use Mix.Project

  def project do
    [
      app: :rendezvous,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :bench},
      {:rustler, "~> 0.22.2"}
      # {:xxh3, "~> 0.3.2"}
    ]
  end
end
