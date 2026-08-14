-- Listing 16.43 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT a.full_name, count(t.resolution_minutes) AS resolved,
       rank() OVER (ORDER BY count(t.resolution_minutes) DESC) AS leaderboard
FROM agent AS a
LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.full_name;
