-- Listing 16.41 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT a.full_name,
       (SELECT count(t.resolution_minutes) FROM ticket AS t
        WHERE t.assigned_agent_id = a.id) AS resolved
FROM agent AS a
ORDER BY resolved DESC;
