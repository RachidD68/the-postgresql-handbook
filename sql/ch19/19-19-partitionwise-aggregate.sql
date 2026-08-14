-- Listing 19.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket_event
WHERE occurred_at >= '2026-01-01 00:00:00+00';
