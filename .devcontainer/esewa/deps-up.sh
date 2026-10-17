#!/usr/bin/env bash
# Starts Postgres, Redis and Superposition, then runs migrations and seeds Superposition.
set -euo pipefail

until docker info >/dev/null 2>&1; do sleep 1; done

docker compose -f docker-compose-development.yml up -d pg redis-standalone superposition
docker compose -f docker-compose-development.yml up migration_runner superposition-init

echo "Dependencies up. Start the router with: cargo run --bin router"
