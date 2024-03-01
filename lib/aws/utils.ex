defmodule EthersKMS.AWS.Utils do
  @moduledoc """
  Utility functions for interacting with AWS KMS
  """

  @elliptic_curve_spec "ECC_SECG_P256K1"
  @key_usage "SIGN_VERIFY"
  @default_description "created through API"
  @default_tags [
    %{
      "TagKey" => "terraform",
      "TagValue" => "false"
    }
  ]
  @aws_alias_prefix "alias/"

  def list_keys(opts \\ []) do
    list_key_opts = extract_key_list_opts(opts)

    with {:ok, %{"Keys" => keys, "Truncated" => is_truncated} = resp} <-
           ExAws.KMS.list_keys(list_key_opts) |> ExAws.request() do
      body = %{
        keys: keys,
        truncated: is_truncated
      }

      result =
        if is_truncated do
          %{"NextMarker" => next_marker} = resp
          Map.merge(body, %{next_marker: next_marker})
        else
          body
        end

      {:ok, result}
    end
  end

  def create_elliptic_key_pair(opts \\ []) do
    with {:ok,
          %{
            "KeyMetadata" => %{
              "KeyId" => key_id
            }
          }} <-
           ExAws.KMS.create_key(
             key_spec: @elliptic_curve_spec,
             key_usage: @key_usage,
             description: @default_description,
             tags: tags_for_key(opts)
           )
           |> ExAws.request() do
      {:ok, key_id}
    end
  end

  def create_key_alias(key_id) do
    ExAws.KMS.create_alias(alias_for_key(), key_id) |> ExAws.request()
  end

  def get_sender_address(key_id) do
    with {:ok, %{"PublicKey" => pem}} <- ExAws.KMS.get_public_key(key_id) |> ExAws.request(),
         {:ok, public_key} <- public_key_from_pem(pem) do
      {:ok, public_key |> Ethers.Utils.public_key_to_address()}
    end
  end

  def public_key_from_pem(pem) do
    pem_head = "-----BEGIN PUBLIC KEY-----\n"
    pem_tail = "\n-----END PUBLIC KEY-----"

    full_pem =
      if String.starts_with?(pem, pem_head) and String.ends_with?(pem, pem_tail) do
        pem
      else
        pem_head <> pem <> pem_tail
      end

    [{type, der, _}] = :public_key.pem_decode(full_pem)

    {_, _, public_key} = :public_key.der_decode(type, der)

    {:ok, public_key}
  end

  def disable_key(key_id) do
    ExAws.KMS.disable_key(key_id) |> ExAws.request()
  end

  def enable_key(key_id) do
    ExAws.KMS.enable_key(key_id) |> ExAws.request()
  end

  defp extract_key_list_opts(opts) do
    [limit: Keyword.get(opts, :limit), marker: Keyword.get(opts, :marker)]
  end

  defp tags_for_key(opts) do
    case Keyword.get(opts, :tags) do
      [tags] -> @default_tags ++ [tags]
      _ -> @default_tags
    end
  end

  defp alias_for_key do
    wallet_alias =
      [
        System.get_env("APP_ENVIRONMENT", "unknown"),
        System.get_env("APP", "app"),
        "wallet",
        "#{System.system_time(:second)}"
      ]
      |> Enum.join("-")

    @aws_alias_prefix <> wallet_alias
  end
end
