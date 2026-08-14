-- Listing 10.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT a.full_name,
       count(t.resolution_minutes)                    AS resolved,
       round(avg(t.resolution_minutes), 0)            AS avg_minutes,
       dense_rank()      OVER by_output               AS tier,
       round(100.0 * count(t.resolution_minutes) /
             sum(count(t.resolution_minutes)) OVER (), 1) AS share_pct
FROM agent AS a
LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.full_name
WINDOW by_output AS (ORDER BY count(t.resolution_minutes) DESC)
ORDER BY resolved DESC, a.full_name;
