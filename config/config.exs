import Config

import_config "#{config_env()}.exs"

config :ethers,
  rpc_client: Ethereumex.HttpClient,
  keccak_module: ExKeccak,
  json_module: Jason,
  secp256k1_module: ExSecp256k1

config :ex_aws,
  access_key_id: CHANGEME,
  secret_access_key: CHANGEME,
  security_token: CHANGEME,
  region: CHANGEME
