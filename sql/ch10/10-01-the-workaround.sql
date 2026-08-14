-- Listing 10.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT t.reference, tm.name AS team, t.resolution_minutes,
       team_avg.avg_minutes
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
JOIN (SELECT team_id, round(avg(resolution_minutes), 0) AS avg_minutes
      FROM ticket
      GROUP BY team_id) AS team_avg
  ON team_avg.team_id = t.team_id
WHERE t.resolution_minutes IS NOT NULL
ORDER BY t.resolution_minutes DESC
LIMIT 6;
