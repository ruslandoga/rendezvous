# pretty much copied from https://github.com/farhadi/xxh3
# except for target is arm64
defmodule XXH3 do
  use Rustler, otp_app: :rendezvous, crate: :xxh3

  @spec hash64(binary) :: pos_integer()
  def hash64(_bin), do: error()

  @spec hash64_with_seed(binary, pos_integer()) :: pos_integer()
  def hash64_with_seed(_bin, _seed), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
