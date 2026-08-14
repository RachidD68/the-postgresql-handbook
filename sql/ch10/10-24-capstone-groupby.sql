-- Listing 10.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
-- Way 2: GROUP BY, then a self-join to count who beat you.
WITH per_agent AS (
    SELECT a.full_name, count(t.resolution_minutes) AS resolved,
           round(avg(t.resolution_minutes), 0) AS avg_minutes
    FROM agent AS a
    LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
    GROUP BY a.full_name
)
SELECT me.full_name, me.resolved, me.avg_minutes,
       count(better.full_name) + 1 AS rank_by_join
FROM per_agent AS me
LEFT JOIN per_agent AS better ON better.resolved > me.resolved
GROUP BY me.full_name, me.resolved, me.avg_minutes
ORDER BY me.resolved DESC, me.full_name;
