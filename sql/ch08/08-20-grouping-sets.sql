-- Listing 8.20 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT tm.name AS team, t.priority, count(*) AS tickets
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
GROUP BY GROUPING SETS ((tm.name), (t.priority), ())
ORDER BY tm.name NULLS LAST, t.priority NULLS LAST;
