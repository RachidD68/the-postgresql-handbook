-- Listing 7.22 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT t.reference, c.company_name, tm.name AS team,
       a.full_name AS agent, tg.name AS tag
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
JOIN team AS tm ON tm.id = t.team_id
LEFT JOIN agent AS a ON a.id = t.assigned_agent_id
JOIN ticket_tag AS tt ON tt.ticket_id = t.id
JOIN tag AS tg ON tg.id = tt.tag_id
WHERE t.status = 'open'
ORDER BY t.reference, tg.name;
