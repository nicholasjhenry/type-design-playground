defmodule TypeDesignPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :type_design_playground,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env != :test
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
      {:typed_struct, "~> 0.1.4"},
      {:mix_test_watch, "~> 0.9.0"},
      {:algae, "~> 1.2"}
    ]
  end
end
