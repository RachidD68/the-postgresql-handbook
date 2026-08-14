-- Listing 8.22 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT CASE WHEN GROUPING(tm.name) = 1 THEN 'ALL TEAMS' ELSE tm.name END AS team,
       count(*) AS tickets,
       round(avg(t.resolution_minutes), 0) AS avg_minutes
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
GROUP BY ROLLUP (tm.name)
ORDER BY GROUPING(tm.name), tm.name;
