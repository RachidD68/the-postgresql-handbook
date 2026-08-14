-- 100-ch19-partitioning.sql — Chapter 19's work product, applied from Chapter 20 onward.
-- Mirrors the chapter's partitioning listings (the book's listings ARE the
-- source; this file replays them so State(N >= 20) matches a reader who
-- followed Ch19). ticket_event becomes a monthly-partitioned table; the
-- original heap survives as ticket_event_flat for the chapter's comparisons.
-- The composite PRIMARY KEY (id, occurred_at) is the partitioning tax the
-- chapter teaches: every unique constraint must include the partition key.

BEGIN;

CREATE TABLE lumina.ticket_event_p (
    id           bigint GENERATED ALWAYS AS IDENTITY,
    ticket_id    bigint NOT NULL,
    event_kind   text NOT NULL,
    payload      jsonb NOT NULL DEFAULT '{}',
    occurred_at  timestamptz NOT NULL,
    PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

-- Chapter 6's foreign key, re-created deliberately on the (still empty)
-- partitioned parent so it survives the swap; validation is free here.
ALTER TABLE lumina.ticket_event_p ADD CONSTRAINT event_ticket_fk
    FOREIGN KEY (ticket_id) REFERENCES lumina.ticket (id) ON DELETE CASCADE;

CREATE TABLE lumina.ticket_event_2025_07 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2025-07-01 00:00:00+00') TO ('2025-08-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2025_08 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2025-08-01 00:00:00+00') TO ('2025-09-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2025_09 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2025_10 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2025_11 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2025_12 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2026_01 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_2026_02 PARTITION OF lumina.ticket_event_p
    FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');
CREATE TABLE lumina.ticket_event_default PARTITION OF lumina.ticket_event_p DEFAULT;

-- Quiesce writes for the copy (reads continue): INSERT ... SELECT alone holds
-- only ACCESS SHARE, and a concurrent write during the copy would land in the
-- old heap and be stranded in ticket_event_flat at COMMIT.
LOCK TABLE lumina.ticket_event IN EXCLUSIVE MODE;

INSERT INTO lumina.ticket_event_p (id, ticket_id, event_kind, payload, occurred_at)
    OVERRIDING SYSTEM VALUE
SELECT id, ticket_id, event_kind, payload, occurred_at
FROM lumina.ticket_event;

SELECT setval(pg_get_serial_sequence('lumina.ticket_event_p', 'id'),
              (SELECT max(id) FROM lumina.ticket_event_p));

ALTER TABLE lumina.ticket_event   RENAME TO ticket_event_flat;
ALTER TABLE lumina.ticket_event_p RENAME TO ticket_event;

COMMIT;

-- Partitioned index: declared once on the parent, cascades to every partition
-- (current and future).
CREATE INDEX event_part_ticket_idx ON lumina.ticket_event (ticket_id);
