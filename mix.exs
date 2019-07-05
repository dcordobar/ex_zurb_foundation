defmodule Zf.Mixfile do
  use Mix.Project

  def project do
    [
      app: :zf,
      version: "0.4.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      applications: [:logger],
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/zf/paginator/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 2.6"},
      {:ex_doc, "~> 0.15", only: :dev},
      {:scrivener, "~> 1.2 or ~> 2.0"},
      {:plug, "~> 1.1" },
      {:earmark, "~> 1.1", only: :dev},
    ]
  end

  defp description do
    """
    Helpers built to work with Phoenix's page struct to easily build HTML output for ZURB Foundation framework.
    """
  end

  defp package do
    [
      # These are the default files included in the package
      name: :ex_zurb_foundation,
      files: ["lib", "config", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Xavier Nouvilas"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/xnouvilas/ex_zurb_foundation"
      }
    ]
  end

end
