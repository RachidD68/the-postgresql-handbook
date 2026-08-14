-- Solution to Exercise 19.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 19,
--              then sql/ch19/19-01, 19-02, 19-03, and the 2026_03 partition
--              from listing 19-13 (the chapter's own partitioning work).

-- Both bounds: the question is fully covered by one declared partition.
EXPLAIN (COSTS OFF)
SELECT id FROM ticket_event
WHERE occurred_at >= '2026-03-01 00:00:00+00'
  AND occurred_at <  '2026-04-01 00:00:00+00';
--  Bitmap Heap Scan on ticket_event_2026_03 ticket_event
--    -> Bitmap Index Scan on ticket_event_2026_03_pkey
-- 2026_03 ALONE survives — no Append, and no DEFAULT: PostgreSQL
-- guarantees DEFAULT holds nothing inside declared ranges, so it prunes
-- away, and scanning the empty 2026_03 costs one page look.

-- Drop the upper bound: the question becomes open-ended.
EXPLAIN (COSTS OFF)
SELECT id FROM ticket_event
WHERE occurred_at >= '2026-03-01 00:00:00+00';
--  Append
--    -> Seq Scan on ticket_event_2026_03
--    -> Seq Scan on ticket_event_default
-- DEFAULT joins the survivors because a stray 2027 row COULD answer an
-- open-ended question — healthy conveyors keep DEFAULT empty precisely so
-- that extra scan stays free.
