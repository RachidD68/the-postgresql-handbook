-- Listing 8.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
-- Wrong: the junction join multiplied the grain before count(*) ran.
SELECT tm.name AS team, count(*) AS tickets
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
JOIN ticket_tag AS tt ON tt.ticket_id = t.id
GROUP BY tm.name
ORDER BY tm.name;

-- Honest: count distinct tickets, whatever the grain got multiplied to.
SELECT tm.name AS team, count(DISTINCT t.id) AS tickets
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
JOIN ticket_tag AS tt ON tt.ticket_id = t.id
GROUP BY tm.name
ORDER BY tm.name;
