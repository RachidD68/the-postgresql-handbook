-- Listing 16.29 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT count(*) FROM ticket WHERE subject LIKE '%export%';

CREATE INDEX ticket_subject_trgm
    ON ticket USING gin (subject gin_trgm_ops);

EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT count(*) FROM ticket WHERE subject LIKE '%export%';

DROP INDEX ticket_subject_trgm;
