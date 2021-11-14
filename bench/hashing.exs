use Bitwise

sha = fn value -> :crypto.hash(:sha, value) end
xxh3 = fn value -> XXH3.hash64(value) end
buckets = ["10.0.1.10", "10.0.2.23", "10.0.0.44"]

buckets_with_seeds =
  Enum.map(buckets, fn bucket ->
    [a, b, c, d] = bucket |> String.split(".") |> Enum.map(&String.to_integer/1)
    seed = (a <<< 24) + (b <<< 16) + (c <<< 8) + d
    {bucket, seed}
  end)

key = "user-socket-1"

Benchee.run(
  %{
    # "hash_fun_sha" => fn -> Rendezvous.get_bucket(buckets, key, hash_fun) end,
    "sha" => fn ->
      buckets
      |> Enum.map(fn bucket -> {bucket, :crypto.hash(:sha, [key | bucket])} end)
      |> Enum.max_by(fn {_bucket, hash} -> hash end)
    end,
    # "xxh3 hash64(key)" => fn ->
    #   buckets
    #   # TODO instead if joining with bucket, precompute seed/secret for bucket and pass that
    #   |> Enum.map(fn bucket -> {bucket, XXH3.hash64(key)} end)
    #   |> Enum.max_by(fn {_bucket, hash} -> hash end)
    # end,
    # "xxh3 hash64(key <> bucket)" => fn ->
    #   buckets
    #   # TODO instead if joining with bucket, precompute seed/secret for bucket and pass that
    #   |> Enum.map(fn bucket -> {bucket, XXH3.hash64(key <> bucket)} end)
    #   |> Enum.max_by(fn {_bucket, hash} -> hash end)
    # end,
    # "xxh3 hash64_with_seed(key, seed)" => fn ->
    #   buckets_with_seeds
    #   # TODO instead of seed, pass precomupted secret
    #   |> Enum.map(fn {bucket, seed} -> {bucket, XXH3.hash64_with_seed(key, seed)} end)
    #   |> Enum.max_by(fn {_bucket, hash} -> hash end)
    # end,
    # "no_max_by" => fn ->
    #   buckets
    #   |> Enum.map(fn bucket -> {bucket, :crypto.hash(:sha, [key | bucket])} end)
    # end,
    # "no_tuple" => fn ->
    #   buckets
    #   |> Enum.map(fn bucket -> :crypto.hash(:sha, [key | bucket]) end)
    # end,
    "map xxh3, no sorting" => fn ->
      Enum.map(buckets_with_seeds, fn {_bucket, seed} -> XXH3.hash64_with_seed(key, seed) end)
    end,
    "map xxh3, in-reduce sorting" => fn ->
      Enum.reduce(buckets_with_seeds, fn {bucket, seed}, {_bucket_max, hash_max} = max ->
        hash = XXH3.hash64_with_seed(key, seed)
        if hash > hash_max, do: _new_max = {bucket, hash}, else: max
      end)
    end,
    "fast_get_bucket" => fn ->
      Rendezvous.fast_get_bucket(buckets_with_seeds, key)
    end
  },
  memory_time: 2
)
