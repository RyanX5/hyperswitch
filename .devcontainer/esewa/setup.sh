#!/usr/bin/env bash
# One-time toolchain setup for the codespace.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  protobuf-compiler libpq-dev libssl-dev pkg-config postgresql-client jq mold

rustup update stable
rustup default stable
rustup toolchain install nightly --profile minimal --component rustfmt

# Prebuilt binaries instead of compiling them from source.
curl -L --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo binstall -y just cargo-generate
cargo binstall -y diesel_cli --no-default-features --features postgres \
  || cargo install diesel_cli --no-default-features --features postgres

echo "Toolchain ready: $(rustc --version)"
