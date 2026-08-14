-- Solution to Exercise 19.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 19
-- Design only — wrapped in a rolled-back transaction to prove it compiles.

BEGIN;

CREATE TABLE ticket_regional (
    id                 bigint GENERATED ALWAYS AS IDENTITY,
    region             text NOT NULL,
    reference          text NOT NULL,
    customer_id        bigint NOT NULL,
    team_id            bigint NOT NULL,
    subject            text NOT NULL,
    body               text NOT NULL,
    status             text NOT NULL,
    priority           text NOT NULL,
    created_at         timestamptz NOT NULL,
    -- The partitioning tax: every unique constraint must include the
    -- partition key, so both of Chapter 2's identities widen.
    PRIMARY KEY (id, region),
    UNIQUE (reference, region)
) PARTITION BY LIST (region);

CREATE TABLE ticket_eu   PARTITION OF ticket_regional FOR VALUES IN ('eu');
CREATE TABLE ticket_us   PARTITION OF ticket_regional FOR VALUES IN ('us');
CREATE TABLE ticket_apac PARTITION OF ticket_regional FOR VALUES IN ('apac');
-- Deliberately NO DEFAULT partition: an unknown region should fail loudly,
-- because "EU data separable on demand" means DETACH PARTITION ticket_eu —
-- clean only if nothing EU-shaped can hide anywhere else.

ROLLBACK;

-- The three sentences:
-- 1. UNIQUE (reference, region) no longer promises global uniqueness —
--    the same reference could exist once per region and the database
--    would shrug.
-- 2. One restoration: a small UNPARTITIONED reference registry
--    (reference text PRIMARY KEY) that every ticket insert writes
--    through; an application-level allocator is the other route.
-- 3. The cost: one extra insert (and its lock) on every ticket, plus a
--    new failure mode you now own. No free lunch; there is a menu.
