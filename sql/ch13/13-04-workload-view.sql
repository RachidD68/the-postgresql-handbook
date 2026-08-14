-- Listing 13.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE VIEW v_agent_workload AS
SELECT a.id, a.full_name, tm.name AS team,
       count(t.id) FILTER (WHERE t.status = 'open') AS open_tickets,
       count(t.id) AS assigned_ever
FROM agent AS a
JOIN team AS tm ON tm.id = a.team_id
LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.id, a.full_name, tm.name;

SELECT full_name, team, open_tickets
FROM v_agent_workload
ORDER BY open_tickets DESC, full_name;
