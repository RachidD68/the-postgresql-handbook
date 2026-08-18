#!/usr/bin/env bash
# reset-to-chapter.sh — POSIX port of reset-to-chapter.ps1.
#
# Reset the lumina database to the state a given chapter expects (ENTRY-state
# semantics: the chapter's own DDL is yours to type as you follow along).
# Connection comes from the standard libpq variables (PGHOST, PGPORT, PGUSER,
# PGPASSWORD), defaulting to localhost:5432 as postgres — which matches the
# companion Docker container.
#
# Usage:  ./reset-to-chapter.sh <chapter 1-23> [--bulk]

set -euo pipefail

CHAPTER="${1:?usage: ./reset-to-chapter.sh <chapter 1-23> [--bulk]}"
BULK="${2:-}"

if ! [[ "$CHAPTER" =~ ^[0-9]+$ ]] || [ "$CHAPTER" -lt 1 ] || [ "$CHAPTER" -gt 23 ]; then
    echo "chapter must be 1..23" >&2
    exit 1
fi

export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA="$REPO/schema"
SEED="$REPO/seed"

# Host psql if available (or $PSQL override); otherwise fall back to running
# psql inside the book's container, piping files over stdin — a Docker-only
# reader needs nothing installed beyond Docker itself.
USE_DOCKER=0
PSQL="${PSQL:-psql}"
if ! command -v "$PSQL" >/dev/null 2>&1; then
    if [ "$(docker inspect -f '{{.State.Running}}' lumina-db 2>/dev/null)" = "true" ]; then
        USE_DOCKER=1
    else
        echo "No psql found and the lumina-db container is not running." >&2
        echo "Start it (docker compose up -d) or install the psql client (Appendix A)." >&2
        exit 1
    fi
fi

run() {
    if [ "$USE_DOCKER" = "1" ]; then
        docker exec -i lumina-db psql -X -q -v ON_ERROR_STOP=1 -U postgres -d "$1" -c "$2"
    else
        "$PSQL" -X -q -v ON_ERROR_STOP=1 -d "$1" -c "$2"
    fi
}
runf() {
    if [ "$USE_DOCKER" = "1" ]; then
        docker exec -i lumina-db psql -X -q -v ON_ERROR_STOP=1 -U postgres -d "$1" -f - < "$2"
    else
        "$PSQL" -X -q -v ON_ERROR_STOP=1 -d "$1" -f "$2"
    fi
}

run postgres "SELECT 1;" >/dev/null || {
    echo "Cannot reach PostgreSQL. Docker readers: docker compose up -d." >&2
    echo "Native readers: check the service and PGPASSWORD (or pgpass.conf)." >&2
    exit 1
}

echo "Resetting lumina to chapter state $CHAPTER on $PGHOST:$PGPORT ..."

# -- Ch20 leftovers: subscriptions and slots block the drops below ------
# The logical-replication demo creates a second database (lumina_replica).
# A database that still holds a subscription refuses DROP DATABASE (FORCE
# only kills sessions), and a leftover logical slot can block dropping
# lumina itself — so detach both first, tolerating absence at every step.
run_tolerant() {
    if [ "$USE_DOCKER" = "1" ]; then
        docker exec -i lumina-db psql -X -q -U postgres -d "$1" -c "$2" >/dev/null 2>&1 || true
    else
        "$PSQL" -X -q -d "$1" -c "$2" >/dev/null 2>&1 || true
    fi
}
query_scalar() {
    if [ "$USE_DOCKER" = "1" ]; then
        docker exec -i lumina-db psql -X -q -t -A -U postgres -d "$1" -c "$2" 2>/dev/null || true
    else
        "$PSQL" -X -q -t -A -d "$1" -c "$2" 2>/dev/null || true
    fi
}
# Scan the WHOLE cluster, not just lumina_replica: a mistyped demo can leave a
# subscription in any database (including lumina itself), and one we miss makes
# every later DROP DATABASE fail. Name-agnostic on both counts, so a reader's
# own experiment cleans up as reliably as the book's.
for db in $(query_scalar postgres "SELECT DISTINCT d.datname FROM pg_subscription s JOIN pg_database d ON d.oid = s.subdbid;"); do
    for sub in $(query_scalar "$db" "SELECT subname FROM pg_subscription;"); do
        run_tolerant "$db" "ALTER SUBSCRIPTION $sub DISABLE;"
        run_tolerant "$db" "ALTER SUBSCRIPTION $sub SET (slot_name = NONE);"
        run_tolerant "$db" "DROP SUBSCRIPTION IF EXISTS $sub;"
    done
done
# An ACTIVE slot refuses pg_drop_replication_slot, so evict its walsender first;
# then drop every slot that remains, whatever it is called.
run_tolerant postgres "SELECT pg_terminate_backend(active_pid) FROM pg_replication_slots WHERE active_pid IS NOT NULL;"
for slot in $(query_scalar postgres "SELECT slot_name FROM pg_replication_slots;"); do
    run_tolerant postgres "SELECT pg_drop_replication_slot('$slot');"
    run_tolerant lumina   "SELECT pg_drop_replication_slot('$slot');"
done

run postgres "DROP DATABASE IF EXISTS lumina WITH (FORCE);"
# Ch17 roles are cluster-level and survive the drop; remove for a clean State(N).
run postgres "DROP ROLE IF EXISTS lumina_app, lumina_readonly, support_agent;"
run postgres "DROP DATABASE IF EXISTS lumina_replica WITH (FORCE);"
run postgres "CREATE DATABASE lumina;"
run postgres "ALTER DATABASE lumina SET jit = off;"
run postgres "ALTER DATABASE lumina SET work_mem = '16MB';"
run postgres "ALTER DATABASE lumina SET random_page_cost = 1.1;"
run postgres "ALTER DATABASE lumina SET max_parallel_workers_per_gather = 2;"
# timestamptz literals and display assume UTC; pin it for reproducible captures.
run postgres "ALTER DATABASE lumina SET timezone = 'UTC';"
run postgres "ALTER DATABASE lumina SET search_path = lumina, public;"

runf lumina "$SCHEMA/000-extensions.sql"
if [ "$CHAPTER" -ge 3 ]; then
    runf lumina "$SCHEMA/010-core-schema.sql"
fi

applied=0
if [ -d "$SCHEMA/migrations" ]; then
    for mig in "$SCHEMA"/migrations/*.sql; do
        [ -e "$mig" ] || continue
        base="$(basename "$mig")"
        migch="$(echo "$base" | sed -n 's/^[0-9]\{3\}-ch\([0-9]\{2\}\)-.*/\1/p')"
        if [ -z "$migch" ]; then
            echo "Migration filename does not match NNN-chMM-slug.sql: $base" >&2
            exit 1
        fi
        migch=$((10#$migch))
        if [ "$migch" -lt "$CHAPTER" ] || { [ "$migch" -eq 23 ] && [ "$CHAPTER" -eq 23 ]; }; then
            runf lumina "$mig"
            applied=$((applied + 1))
        fi
    done
fi

seeds="none (schema only)"
if [ "$CHAPTER" -ge 3 ]; then
    runf lumina "$SEED/seed-core.sql" >/dev/null
    seeds="core"
fi
if { [ "$CHAPTER" -ge 15 ] || [ "$BULK" = "--bulk" ]; } && [ -f "$SEED/seed-bulk.sql" ]; then
    runf lumina "$SEED/seed-bulk.sql" >/dev/null
    seeds="$seeds, bulk"
fi
if [ "$CHAPTER" -ge 23 ] && [ -f "$SEED/seed-kb.sql" ]; then
    runf lumina "$SEED/seed-kb.sql" >/dev/null
    seeds="$seeds, kb"
fi

# Migration 040's custom_fields backfill met an empty ticket table (migrations
# run before seeds); re-apply it on real rows so State(N) matches a reader who
# ran Ch11's listings. The file is written to be applied twice — see its header.
if [ "$CHAPTER" -ge 12 ]; then
    runf lumina "$SCHEMA/migrations/040-ch11-jsonb.sql" >/dev/null
fi

# Matviews in migrations snapshot an empty ticket table; refresh post-seed.
if [ "$CHAPTER" -ge 14 ]; then
    run lumina "REFRESH MATERIALIZED VIEW lumina.mv_monthly_stats;"
fi

run lumina "VACUUM (ANALYZE);"
echo "Done. Chapter state $CHAPTER — migrations applied: $applied, seeds: $seeds."
