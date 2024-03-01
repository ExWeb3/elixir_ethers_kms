defmodule EthersKMS.AWS.UtilsTest do
  use ExUnit.Case
  use Mimic

  alias EthersKMS.AWS.Utils
  alias EthersKMS.KMSFixtures

  describe "list_keys/0" do
    test "list keys on aws kms with truncated response" do
      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_list_keys_truncated_response()
      end)

      assert {:ok,
              %{
                keys: [
                  %{
                    "KeyArn" =>
                      "arn:aws:kms:us-west-2:232250609916:key/0eb05eb7-faa7-4a65-8fc5-bf5615d1c73b",
                    "KeyId" => "0eb05eb7-faa7-4a65-8fc5-bf5615d1c73b"
                  }
                ],
                next_marker:
                  "AE0AAAACAHMAAAAJYWNjb3VudElkAHMAAAAMMjMyMjUwNjA5OTE2AHMAAAAEdGtJZABzAAAAJDBlYjA1ZWI3LWZhYTctNGE2NS04ZmM1LWJmNTYxNWQxYzczYg",
                truncated: true
              }} == Utils.list_keys(limit: 1)
    end

    test "list keys on aws kms with full response" do
      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_list_keys_response()
      end)

      assert {:ok,
              %{
                keys: [
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
                truncated: false
              }} == Utils.list_keys()
    end
  end

  describe "create_elliptic_key_pair/0" do
    test "create a elliptic curve key pairs on aws kms" do
      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_key_creation_response()
      end)

      key_id = "c3d230fb-b257-482a-9c84-a3962b71debc"

      assert {:ok, key_id} == Utils.create_elliptic_key_pair()
    end
  end

  describe "create_key_alias/1" do
    test "create a key alias on aws kms" do
      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_key_alias_response()
      end)

      key_id = "c3d230fb-b257-482a-9c84-a3962b71debc"

      assert {:ok, nil} == Utils.create_key_alias(key_id)
    end
  end

  describe "get_sender_address/1" do
    test "get sender wallet address by converting the pem received from aws" do
      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_public_key_response()
      end)

      key_id = "c3d230fb-b257-482a-9c84-a3962b71debc"
      wallet = "0x4eed49289Ac2876C9c966FC16b22F6eC5bf0817c"

      assert {:ok, wallet} == Utils.get_sender_address(key_id)
    end
  end

  describe "disable_key/1" do
    test "disable a key on aws kms" do
      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_key_disable_response()
      end)

      key_id = "c3d230fb-b257-482a-9c84-a3962b71debc"

      assert {:ok, nil} == Utils.disable_key(key_id)
    end

    test "disable a non-existent key on aws kms" do
      key_id = "xyz"

      expect(ExAws, :request, fn _ ->
        KMSFixtures.kms_key_disable_not_found_response(key_id)
      end)

      assert {:error, _error_msg} = Utils.disable_key(key_id)
    end
  end
end
