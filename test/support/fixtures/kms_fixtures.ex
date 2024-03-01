defmodule EthersKMS.KMSFixtures do
  @moduledoc """
  This module defines fixtures for Signers.
  """

  def kms_list_keys_truncated_response do
    {:ok,
     %{
       "KeyCount" => 1,
       "Keys" => [
         %{
           "KeyArn" =>
             "arn:aws:kms:us-west-2:232250609916:key/0eb05eb7-faa7-4a65-8fc5-bf5615d1c73b",
           "KeyId" => "0eb05eb7-faa7-4a65-8fc5-bf5615d1c73b"
         }
       ],
       "NextMarker" =>
         "AE0AAAACAHMAAAAJYWNjb3VudElkAHMAAAAMMjMyMjUwNjA5OTE2AHMAAAAEdGtJZABzAAAAJDBlYjA1ZWI3LWZhYTctNGE2NS04ZmM1LWJmNTYxNWQxYzczYg",
       "Truncated" => true
     }}
  end

  def kms_list_keys_response do
    {:ok,
     %{
       "KeyCount" => 2,
       "Keys" => [
         %{
           "KeyArn" =>
             "arn:aws:kms:us-west-2:232250609916:key/0eb05eb7-faa7-4a65-8fc5-bf5615d1c73b",
           "KeyId" => "0eb05eb7-faa7-4a65-8fc5-bf5615d1c73b"
         },
         %{
           "KeyArn" =>
             "arn:aws:kms:us-west-2:232250609916:key/fc038303-ea86-43fb-b277-265398349e6e",
           "KeyId" => "fc038303-ea86-43fb-b277-265398349e6e"
         }
       ],
       "Truncated" => false
     }}
  end

  def kms_public_key_response do
    {:ok,
     %{
       "PublicKey" =>
         "MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEsdTvgjvTDk/BF/COdU/4/v6HgCaceKifvcBfxKnZpCt5wFzZEgwWSLTsz1T9YaCaS0Xb0D0g7TaT8VAD+Tesmg=="
     }}
  end

  def kms_sign_response do
    {:ok,
     %{
       "Signature" =>
         "MEUCIDK6M5izIjRFuFiEniddbbsaZwjzBbsrjEJxQ/kjm7m+AiEArAX1ZsnrEthrafd+uH2PeEQ+VAN08CH/pxzG/UV2KFw="
     }}
  end

  def kms_key_creation_response do
    {:ok,
     %{
       "KeyMetadata" => %{
         "KeyId" => "c3d230fb-b257-482a-9c84-a3962b71debc"
       }
     }}
  end

  def kms_key_alias_response do
    {:ok, nil}
  end

  def kms_key_disable_response do
    {:ok, nil}
  end

  def kms_key_disable_not_found_response(key_id) do
    {:error, {"NotFoundException", "Invalid keyId #{key_id}"}}
  end

  def kms_key_enable_response do
    {:ok, nil}
  end
end
