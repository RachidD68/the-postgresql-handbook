-- Solution to Exercise 2.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 3
-- (State 3 is Chapter 2's finished work product: the core schema exists.)

CREATE TABLE kb_article (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id    bigint NOT NULL,      -- every article has an author
    ticket_id   bigint,               -- "optionally born from a ticket": nullable
    title       text NOT NULL,        -- an untitled article cannot be found
    body        text NOT NULL,        -- an empty article helps nobody
    created_at  timestamptz NOT NULL  -- provenance is not optional
);

-- The conspicuously absent constraint is NOT NULL on ticket_id: an article
-- distilled from a ticket points at it; general knowledge points at nothing.
-- Chapter 23's shipped kb_article keeps exactly this nullable ticket_id.
