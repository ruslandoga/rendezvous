defmodule Rendezvous do
  @moduledoc "Basic rendezvous hashing with pluggable hash function"

  # TODO do weighted version
  @doc """
  Non-optimized approach to calculate rendezvous hash for key given a list of buckets and a hash function.

      iex> hash_fun = fn value -> :crypto.hash(:sha, value) end
      iex> nodes = ["10.0.1.10", "10.0.2.23", "10.0.0.44"]
      iex> get_bucket(nodes, "user-socket-1234", hash_fun)
      {"10.0.0.44", <<137, 135, 109, 212, 105, 129, 231, 35, 130, 248, 45, 120, 181, 112, 88, 224, 128, 54, 251, 215>>}

  """
  @spec slow_get_bucket([bucket], key, (iolist() -> hash)) :: {bucket, hash}
        when bucket: binary, key: binary, hash: term
  def slow_get_bucket(buckets, key, hash_fun) do
    buckets
    |> Enum.map(fn bucket -> {bucket, hash_fun.([key | bucket])} end)
    |> Enum.max_by(fn {_bucket, hash} -> hash end)
  end

  def fast_get_bucket([{bucket, seed} | rest], key) do
    hash = XXH3.hash64_with_seed(key, seed)
    fast_get_bucket(rest, key, hash, bucket)
  end

  defp fast_get_bucket([{bucket, seed} | rest], key, max_hash, max_bucket) do
    hash = XXH3.hash64_with_seed(key, seed)

    # TODO hash = max_hash, low prob but possible, use pre-sorted buckets
    if hash > max_hash do
      fast_get_bucket(rest, key, hash, bucket)
    else
      fast_get_bucket(rest, key, max_hash, max_bucket)
    end
  end

  defp fast_get_bucket([], _key, max_hash, max_bucket) do
    {max_hash, max_bucket}
  end
end

# TODO figure out handoff api (check riak_core, horde)
# read-replicas at top-3?

# defmodule Rendezvous.Server do
#   @callback handle_handover(to :: pid, state :: term) :: {:ok, state :: term}
# end

# defmodule Nomad do
#   @moduledoc "A digital nomad travelling through nodes in the cluster"
#   use GenServer
#   @behaviour Rendezvous.Server

#   @impl GenServer
#   def init(opts) do
#     {:ok, opts}
#   end

#   @impl Rendezvous.Server
#   def handle_handover(pid, state) do
#     send(pid, {:handover, state})
#     {:ok, state}
#   end

#   @impl GenServer
#   def handle_info({:handover, prev_state}, new_state) do
#     state = Keyword.merge(prev_state, new_state)
#     {:noreply, state}
#   end
# end

# defmodule Rendezvous.Distribution do
#   use GenServer

#   @impl true
#   def init(opts) do
#     :net_kernel.monitor_nodes(true)
#     {:ok, opts}
#   end

#   @impl true
#   def handle_info({:nodeup, node}, state) do
#     handover_processes(node)
#     {:noreply, state}
#   end

#   def handle_info({:nodedown, _node}, state) do
#     {:noreply, state}
#   end

#   @spec processes_to_hand_over(node, node) :: [{pid, name :: term}]
#   def processes_to_hand_over(to_node, from_node \\ node()) do
#     [_, to] = to_node |> to_string() |> String.split("@")
#     [_, from] = from_node |> to_string() |> String.split("@")

#     current_processes = Registry.select(...)

#     Enum.filter(current_processes, fn {_pid, name} ->
#       current_hash = :crypto.hash(:sha, [name | from])
#       new_hash = :crypto.hash(:sha, [name | to])

#       cond do
#         new_hash > current_hash -> true
#         # TODO
#         new_hash == current_hash -> to > from
#         true -> false
#       end
#     end)
#   end
# end
