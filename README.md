# Ethers - KMS Signer

ethers_kms is a signer library for [Ethers](https://github.com/ExWeb3/elixir_ethers) using a Key Management Service such [AWS KMS](https://aws.amazon.com/kms/) apart from the built-in [signers](https://github.com/ExWeb3/elixir_ethers/blob/main/lib/ethers/signer/local.ex) supported by Ethers.


## Installation

You can install the package by adding `ethers_kms` to the list of
dependencies in your `mix.exs` file:

```elixir
def deps do
  [
    {:ethers_kms, "~> 0.0.1"},
  ]
end
```

The complete documentation is available on [hexdocs](https://hexdocs.pm/ethers_kms).
