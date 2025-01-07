defmodule EthersKMS.MixProject do
  use Mix.Project

  @version "0.0.3"
  @source_url "https://github.com/ExWeb3/elixir_ethers_kms"

  def project do
    [
      app: :ethers_kms,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "A KMS based signer library for Ethers.",
      package: package(),
      docs: docs(),
      dialyzer: dialyzer()
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Wen Chen"],
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"]
    ]
  end

  defp docs do
    source_ref =
      if String.ends_with?(@version, "-dev") do
        "main"
      else
        "v#{@version}"
      end

    [
      main: "readme",
      extras: [
        "README.md": [title: "Introduction"]
      ],
      source_url: @source_url,
      source_ref: source_ref,
      markdown_processor: {ExDoc.Markdown.Earmark, footnotes: true}
    ]
  end

  def dialyzer do
    [flags: [:error_handling, :extra_return, :underspecs, :unknown, :unmatched_returns]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:configparser_ex, "~> 4.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ethers, "~> 0.6.0"},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_aws, "~> 2.5.1"},
      {:ex_aws_kms, "~> 2.3.2"},
      {:ex_aws_sts, "~> 2.3.0"},
      {:ex_doc, "~> 0.31.0", only: :dev, runtime: false},
      {:ex_secp256k1, "~> 0.7.2"},
      {:mimic, "~> 1.7", only: :test},
      {:sweet_xml, "~> 0.7.4"}
    ]
  end
end
