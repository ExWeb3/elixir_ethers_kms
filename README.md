# EthersKMS - a KMS Signer for Ethers

EthersKMS is a signer library for [Ethers](https://github.com/ExWeb3/elixir_ethers) using a Key Management Service such as [AWS KMS](https://aws.amazon.com/kms/) apart from the built-in [signers](https://github.com/ExWeb3/elixir_ethers/blob/main/lib/ethers/signer/local.ex) supported by Ethers.


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

## AWS configuration

```elixir
config :ex_aws,
  access_key_id: CHANGEME,
  secret_access_key: CHANGEME,
  security_token: CHANGEME,
  region: CHANGEME
end
```

A [WebIdentityAdapter](https://github.com/ex-aws/ex_aws_sts?tab=readme-ov-file#using-web-identity-tokens-from-env-vars) can also be used in deployed environments.

## Example

```elixir
MyERC20Token.transfer("0x[Recipient]", 1000)
|> Ethers.send(
  from: "0x[Sender]",
  signer: EthersKMS.AWS.Signer,
  # NOTE: provide a valid kms_key_id here (i.e., ECC_SECG_P256K1 key spec)
  signer_opts: [kms_key_id: kms_key_id]
)
```

The complete documentation is available on [hexdocs](https://hexdocs.pm/ethers_kms/readme.html/).
