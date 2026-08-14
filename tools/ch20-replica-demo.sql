-- ch20-replica-demo.sql — the full logical-replication live demo (Chapter 20).
-- Requires wal_level = logical (the companion container sets it; native
-- installs set it in postgresql.conf and restart).
--
-- Run with:  psql -d lumina -f tools/ch20-replica-demo.sql
-- Clean up:  the final block, or scripts/reset-to-chapter.ps1 (any chapter),
--            which drops lumina_replica defensively.

-- ── publisher side (database lumina) ───────────────────────────────
CREATE PUBLICATION lumina_pub FOR TABLE lumina.ticket;

CREATE DATABASE lumina_replica;

-- ── subscriber side ─────────────────────────────────────────────────
\c lumina_replica

CREATE SCHEMA lumina;
-- DDL does not replicate: the subscriber needs the table shape up front.
-- For real schemas use: pg_dump -d lumina --schema-only -t lumina.ticket | psql -d lumina_replica
CREATE TABLE lumina.ticket (
    id                bigint PRIMARY KEY,
    reference         text NOT NULL,
    customer_id       bigint NOT NULL,
    assigned_agent_id bigint,
    team_id           bigint NOT NULL,
    subject           text NOT NULL,
    body              text NOT NULL,
    status            text NOT NULL,
    priority          text NOT NULL,
    channel           text NOT NULL,
    created_at        timestamptz NOT NULL,
    first_response_at timestamptz,
    resolved_at       timestamptz,
    closed_at         timestamptz,
    satisfaction      smallint,
    -- Generated columns are not published (publish_generated_columns = 'none');
    -- computing them locally is exactly what pg_dump --schema-only would give you.
    resolution_minutes integer
        GENERATED ALWAYS AS
            ((EXTRACT(EPOCH FROM (resolved_at - created_at)) / 60)::integer)
        STORED,
    custom_fields     jsonb,
    search_tsv        tsvector
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', subject), 'A') ||
            setweight(to_tsvector('english', body),    'B')
        ) STORED,
    updated_at        timestamptz
);

CREATE SUBSCRIPTION lumina_sub
    CONNECTION 'host=localhost dbname=lumina user=postgres'
    PUBLICATION lumina_pub;

-- Give the initial copy a moment, then compare.
SELECT pg_sleep(5);
SELECT count(*) AS replicated_tickets FROM lumina.ticket;

-- ── the payoff: write on the publisher, read on the subscriber ─────
\c lumina
INSERT INTO lumina.ticket (reference, customer_id, team_id, subject, body,
                           status, priority, channel, created_at)
VALUES ('LUM-90001', 3, 3, 'Logical replication demo', 'Watch me appear next door.',
        'open', 'low', 'web', '2026-01-15 10:00:00+00');

SELECT pg_sleep(2);

\c lumina_replica
SELECT reference, subject FROM lumina.ticket WHERE reference = 'LUM-90001';

-- ── cleanup ─────────────────────────────────────────────────────────
DROP SUBSCRIPTION lumina_sub;
\c lumina
DROP DATABASE lumina_replica;
DROP PUBLICATION lumina_pub;
DELETE FROM lumina.ticket WHERE reference = 'LUM-90001';
