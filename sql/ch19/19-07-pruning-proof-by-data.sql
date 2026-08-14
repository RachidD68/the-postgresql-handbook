-- Listing 19.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
SELECT tableoid::regclass AS physical_table, count(*)
FROM ticket_event
WHERE occurred_at >= '2025-12-01 00:00:00+00'
  AND occurred_at <  '2026-01-01 00:00:00+00'
GROUP BY tableoid
ORDER BY physical_table;
