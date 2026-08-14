-- Listing 15.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX ticket_open_created_idx
    ON ticket (created_at)
    WHERE status = 'open';

CREATE INDEX ticket_created_full_idx ON ticket (created_at);

SELECT pg_size_pretty(pg_relation_size('ticket_open_created_idx')) AS partial,
       pg_size_pretty(pg_relation_size('ticket_created_full_idx'))  AS full_size;

DROP INDEX ticket_created_full_idx;
