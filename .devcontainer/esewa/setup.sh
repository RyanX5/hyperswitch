#!/usr/bin/env bash
# One-time toolchain setup for the codespace.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  protobuf-compiler libprotobuf-dev libpq-dev libssl-dev pkg-config postgresql-client jq mold

rustup update stable
rustup default stable
rustup toolchain install nightly --profile minimal --component rustfmt

# Prebuilt binaries instead of compiling them from source.
curl -L --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo binstall -y just cargo-generate
# Same installer the upstream migration_runner container uses.
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/diesel-rs/diesel/releases/latest/download/diesel_cli-installer.sh | sh

# Go yq, needed by scripts/seed_superposition.sh.
sudo curl -sSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

echo "Toolchain ready: $(rustc --version)"
