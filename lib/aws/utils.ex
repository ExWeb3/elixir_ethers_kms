defmodule EthersKMS.AWS.Utils do
  @moduledoc """
  Util functions for KMS Signer.
  """

  @doc """
  Extract public key from a pem. Binaries of the public key is returned.
  ## Examples
      iex> Utils.public_key_from_pem("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjtGIk8SxD+OEiBpP2/TJUAF0upwuKGMk6wH8Rwov88VvzJrVm2NCticTk5FUg+UG5r8JArrV4tJPRHQyvqKwF4NiksuvOjv3HyIf4oaOhZjT8hDne1Bfv+cFqZJ61Gk0MjANh/T5q9vxER/7TdUNHKpoRV+NVlKN5bEU/NQ5FQjVXicfswxh6Y6fl2PIFqT2CfjD+FkBPU1iT9qyJYHA38IRvwNtcitFgCeZwdGPoxiPPh1WHY8VxpUVBv/2JsUtrB/rAIbGqZoxAIWvijJPe9o1TY3VlOzk9ASZ1AeatvOir+iDVJ5OpKmLnzc46QgGPUsjIyo6Sje9dxpGtoGQQIDAQAB")
  """
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
end
