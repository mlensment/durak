defmodule Durak.Mixfile do
  use Mix.Project

  def project do
    [app: :durak,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env), mod: {Durak, []}]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:logger, :cowboy, :plug, :poison]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:cowboy, "~> 1.0.0"},
    {:plug, "~> 0.12"},
    {:poison, "~> 1.4.0"},
    {:secure_random, "~> 0.5.0"},
    {:remix, "~> 0.0.1", only: :dev}]
  end
end
