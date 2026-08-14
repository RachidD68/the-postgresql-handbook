-- Listing 16.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT priority, created_at
FROM ticket
WHERE assigned_agent_id = 105 AND status = 'open';
