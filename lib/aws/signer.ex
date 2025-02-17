defmodule EthersKMS.AWS.Signer do
  @moduledoc """
  KMS signer works with a AWS KMS Key.
  ## Signer Options
    - `:kms_key_id`: The KMS Key ID.
  """

  @behaviour Ethers.Signer

  import Ethers

  alias Ethers.Transaction
  alias Ethers.Transaction.Signed
  alias Ethers.Utils, as: EthersUtils
  alias EthersKMS.AWS.Utils

  # NOTE: Max value on curve / https://github.com/ethereum/EIPs/blob/master/EIPS/eip-2.md
  @secp256_k1_n 115_792_089_237_316_195_423_570_985_008_687_907_852_837_564_279_074_904_382_605_163_141_518_161_494_337

  @impl true
  def sign_transaction(transaction, opts) do
    with {:ok, key_id} <- get_kms_key(opts),
         {:ok, %{"PublicKey" => pem}} <- ExAws.KMS.get_public_key(key_id) |> ExAws.request(),
         {:ok, public_key} <- Utils.public_key_from_pem(pem),
         :ok <- validate_public_key(public_key, Keyword.get(opts, :from)) do
      {:ok, {r, s, recovery_id}} =
        transaction
        |> Transaction.encode()
        |> keccak_module().hash_256()
        |> Base.encode64()
        |> sign(key_id, public_key)

      signed_transaction =
        %Signed{
          payload: transaction,
          signature_r: r,
          signature_s: s,
          signature_y_parity_or_v: Signed.calculate_y_parity_or_v(transaction, recovery_id)
        }

      encoded_signed_transaction = Transaction.encode(signed_transaction)

      {:ok, EthersUtils.hex_encode(encoded_signed_transaction)}
    end
  end

  defp get_kms_key(opts) do
    case Keyword.get(opts, :kms_key_id) do
      nil ->
        {:error, :kms_key_not_found}

      key_id ->
        {:ok, key_id}
    end
  end

  defp validate_public_key(_public_key, nil), do: {:error, :no_from_address}

  defp validate_public_key(public_key, from_address) do
    derived_address = EthersUtils.public_key_to_address(public_key)
    from_address = EthersUtils.to_checksum_address(from_address)

    if derived_address == from_address do
      :ok
    else
      {:error, :wrong_public_key}
    end
  end

  defp sign(message, key_id, public_key) do
    with {:ok, %{"Signature" => signature}} <-
           ExAws.KMS.sign(message, key_id, "ECDSA_SHA_256", message_type: "DIGEST")
           |> ExAws.request() do
      # extract r and s from the signature
      {r, s} = extract_rs_from_signature(signature)

      # determine recovery_id
      {:ok, recovery_id} = calculate_v(message, r, s, public_key)

      {:ok, {r, s, recovery_id}}
    end
  end

  defp extract_rs_from_signature(signature) do
    decoded_signature = Base.decode64!(signature)
    {:"ECDSA-Sig-Value", r, s} = :public_key.der_decode(:"ECDSA-Sig-Value", decoded_signature)

    # NOTE: Because of EIP-2 not all elliptic curve signatures are accepted,
    # the value of s needs to be smaller than half of the curve.
    s =
      case s > @secp256_k1_n / 2 do
        true -> @secp256_k1_n - s
        _ -> s
      end

    encoded_r = r |> :binary.encode_unsigned()
    encoded_s = s |> :binary.encode_unsigned()

    {encoded_r, encoded_s}
  end

  defp calculate_v(message, signature_r, signature_s, public_key) do
    decoded_message = message |> Base.decode64!()

    # NOTE: recovery_id can only be 0 or 1. If we can recover from the signature the same public key
    # as the one used for signing then that is the right value.
    case secp256k1_module().recover(decoded_message, signature_r, signature_s, 0) do
      {:ok, pub_key_from_sig} ->
        if public_key == pub_key_from_sig do
          {:ok, 0}
        else
          {:ok, 1}
        end

      _ ->
        {:error, :ecrecover_error}
    end
  end

  @impl true
  def accounts(_opts) do
    {:error, :not_supported}
  end
end
