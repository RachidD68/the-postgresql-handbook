-- Listing 19.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
EXPLAIN (COSTS OFF)
SELECT id FROM ticket_event
WHERE occurred_at::date = '2025-12-15'
LIMIT 5;
