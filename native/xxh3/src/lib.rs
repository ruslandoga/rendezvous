use rustler::types::binary::Binary;
use rustler::{Env, Term};
use xxhash_rust::xxh3::{self};

fn on_load(_env: Env, _info: Term) -> bool {
    true
}

#[rustler::nif]
fn hash64(data: Binary) -> u64 {
    xxh3::xxh3_64(data.as_slice())
}

#[rustler::nif]
fn hash64_with_seed(data: Binary, seed: u64) -> u64 {
    xxh3::xxh3_64_with_seed(data.as_slice(), seed)
}

rustler::init!("Elixir.XXH3", [hash64, hash64_with_seed], on_load = on_load);
