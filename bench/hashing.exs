sha = fn value -> :crypto.hash(:sha, value) end
xxh3 = fn value -> XXH3.hash64(value) end
buckets = ["10.0.1.10", "10.0.2.23", "10.0.0.44"]
key = "user-socket-1"

Benchee.run(
  %{
    # "hash_fun_sha" => fn -> Rendezvous.get_bucket(buckets, key, hash_fun) end,
    "direct_sha" => fn ->
      buckets
      |> Enum.map(fn bucket -> {bucket, :crypto.hash(:sha, [key | bucket])} end)
      |> Enum.max_by(fn {_bucket, hash} -> hash end)
    end,
    "direct_xxh3" => fn ->
      buckets
      |> Enum.map(fn bucket -> {bucket, XXH3.hash64(key <> bucket)} end)
      |> Enum.max_by(fn {_bucket, hash} -> hash end)
    end
    # "no_max_by" => fn ->
    #   buckets
    #   |> Enum.map(fn bucket -> {bucket, :crypto.hash(:sha, [key | bucket])} end)
    # end,
    # "no_tuple" => fn ->
    #   buckets
    #   |> Enum.map(fn bucket -> :crypto.hash(:sha, [key | bucket]) end)
    # end,
    # "no_tuple_xxh3" => fn ->
    #   buckets
    #   |> Enum.map(fn bucket -> XXH3.hash64(key <> bucket) end)
    # end
  },
  memory_time: 2
)
