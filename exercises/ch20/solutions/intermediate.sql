-- Solution to Exercise 20.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 20
-- Requires wal_level = logical. Run with:
--   psql -d lumina -f exercises/ch20/solutions/intermediate.sql

-- Publisher side: the row-filtered publication (listing 20.7's shape).
CREATE PUBLICATION open_board FOR TABLE ticket
    WHERE (status = 'open');

SELECT count(*) AS publisher_open FROM ticket WHERE status = 'open';
-- 6,547 at State 20.

-- Same-cluster wrinkle, found the hard way: when the subscriber lives in
-- the SAME cluster as the publisher, a plain CREATE SUBSCRIPTION hangs
-- forever — its remote slot creation waits for every in-progress
-- transaction, including the uncommitted CREATE SUBSCRIPTION itself.
-- The documented cure: create the slot separately, then subscribe with
-- create_slot = false.
SELECT pg_create_logical_replication_slot('open_sub', 'pgoutput');

CREATE DATABASE lumina_replica;

\c lumina_replica

-- DDL does not replicate: the subscriber needs the shape up front
-- (tools/ch20-replica-demo.sql's table, generated columns computed locally).
CREATE SCHEMA lumina;
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

CREATE SUBSCRIPTION open_sub
    CONNECTION 'host=localhost dbname=lumina user=postgres'
    PUBLICATION open_board
    WITH (create_slot = false, slot_name = 'open_sub');

-- Give the initial sync a few seconds, then prove the filter:
SELECT pg_sleep(5);
SELECT count(*) AS replicated FROM lumina.ticket;
-- 6,547 — exactly the publisher's open count, none of the other 73,493.

-- One open and one closed ticket on the publisher:
\c lumina
INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                    status, priority, channel, created_at)
VALUES ('LUM-90001', 3, 3, 'Row filter demo, open',
        'Should appear on the replica.', 'open', 'low', 'web',
        '2026-01-15 10:00:00+00'),
       ('LUM-90002', 3, 3, 'Row filter demo, closed',
        'Should never leave home.', 'closed', 'low', 'web',
        '2026-01-15 10:00:00+00');

SELECT pg_sleep(2);

\c lumina_replica
SELECT reference, status
FROM lumina.ticket
WHERE reference IN ('LUM-90001', 'LUM-90002');
-- One row: LUM-90001, open. The closed ticket failed the row filter.

-- Cleanup, IN ORDER — subscription first (this also removes the
-- publisher-side slot), then the publication. A row-filtered publication
-- left standing blocks every UPDATE and DELETE on the publisher's ticket
-- table, because status is not part of the replica identity.
DROP SUBSCRIPTION open_sub;

\c lumina
DROP DATABASE lumina_replica;
DROP PUBLICATION open_board;
DELETE FROM ticket WHERE reference IN ('LUM-90001', 'LUM-90002');
