-- Listing 10.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT t.reference, tm.name AS team, t.resolution_minutes,
       round(avg(t.resolution_minutes)
             OVER (PARTITION BY t.team_id), 0) AS team_avg
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
WHERE t.resolution_minutes IS NOT NULL
ORDER BY t.resolution_minutes DESC
LIMIT 6;
