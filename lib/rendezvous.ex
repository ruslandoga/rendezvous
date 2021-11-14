defmodule Rendezvous do
  @moduledoc "Basic rendezvous hashing with pluggable hash function"

  @doc """
  Non-optimized approach to calculate rendezvous hash for key given a list of buckets and a hash function.

      iex> hash_fun = fn value -> :crypto.hash(:sha, value) end
      iex> nodes = ["10.0.1.10", "10.0.2.23", "10.0.0.44"]
      iex> get_bucket(nodes, "user-socket-1234", hash_fun)
      {"10.0.0.44", <<137, 135, 109, 212, 105, 129, 231, 35, 130, 248, 45, 120, 181, 112, 88, 224, 128, 54, 251, 215>>}

  """
  @spec get_bucket([bucket], key, (iolist() -> hash)) :: {bucket, hash}
        when bucket: binary, key: binary, hash: term
  def get_bucket(buckets, key, hash_fun) do
    buckets
    |> Enum.map(fn bucket -> {bucket, hash_fun.([key | bucket])} end)
    |> Enum.max_by(fn {_bucket, hash} -> hash end)
  end
end
