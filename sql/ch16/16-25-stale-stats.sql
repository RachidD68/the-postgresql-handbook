-- Listing 16.25 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
CREATE TABLE event_scratch AS SELECT * FROM ticket_event;
VACUUM (ANALYZE) event_scratch;

DELETE FROM event_scratch WHERE occurred_at < '2026-01-01 00:00:00+00';

EXPLAIN SELECT count(*) FROM event_scratch
WHERE occurred_at >= '2025-07-01 00:00:00+00';

ANALYZE event_scratch;

EXPLAIN SELECT count(*) FROM event_scratch
WHERE occurred_at >= '2025-07-01 00:00:00+00';

DROP TABLE event_scratch;
