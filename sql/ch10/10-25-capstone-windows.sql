-- Listing 10.25 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
-- Way 3: windows. Every idea gets its word.
SELECT a.full_name,
       count(t.resolution_minutes)                          AS resolved,
       round(avg(t.resolution_minutes), 0)                  AS avg_minutes,
       rank() OVER (ORDER BY count(t.resolution_minutes) DESC) AS leaderboard,
       round(100.0 * count(t.resolution_minutes) /
             sum(count(t.resolution_minutes)) OVER (), 1)   AS share_pct
FROM agent AS a
LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.full_name
ORDER BY leaderboard, a.full_name;
