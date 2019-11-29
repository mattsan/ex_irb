defmodule ExIRB.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_irb,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_marshal, github: "mattsan/ex_marshal"}
    ]
  end
end
