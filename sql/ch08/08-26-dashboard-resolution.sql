-- Listing 8.26 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT tm.name AS team,
       count(t.resolution_minutes)            AS resolved_tickets,
       round(avg(t.resolution_minutes), 0)    AS avg_minutes,
       max(t.resolution_minutes)              AS worst_minutes
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
GROUP BY tm.name
ORDER BY avg_minutes;
