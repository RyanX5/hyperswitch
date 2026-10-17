#!/usr/bin/env bash
# Starts Postgres, Redis and Superposition, then runs migrations and seeds Superposition.
set -euo pipefail

until docker info >/dev/null 2>&1; do sleep 1; done

docker compose -f docker-compose-development.yml up -d pg redis-standalone superposition
until docker compose -f docker-compose-development.yml exec -T pg pg_isready -U db_user >/dev/null 2>&1; do sleep 1; done

# Migrations apply fine; the schema.rs patch step that follows can fail with a newer
# diesel_cli ("error applying hunk"). That doesn't affect the database, so don't stop.
DATABASE_URL=postgresql://db_user:db_pass@localhost:5432/hyperswitch_db just migrate \
  || echo "just migrate exited non-zero (expected: schema.rs patch step)"
git checkout -- crates/diesel_models/src/schema.rs 2>/dev/null || true

# The compose superposition-init runs this bash script with busybox sh, which fails,
# so seed from here with bash instead.
until curl -sf http://localhost:8081/health >/dev/null 2>&1; do sleep 2; done
SUPERPOSITION_URL=http://localhost:8081 bash scripts/seed_superposition.sh >/tmp/seed.log 2>&1 \
  && echo "Superposition seeded" || echo "Seed failed, see /tmp/seed.log"

echo "Dependencies up. Start the router with: cargo run --bin router"
