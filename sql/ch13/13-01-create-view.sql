-- Listing 13.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE VIEW v_open_ticket AS
SELECT t.id, t.reference, t.subject, c.company_name,
       tm.name AS team, a.full_name AS agent,
       t.priority, t.created_at
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
JOIN team AS tm ON tm.id = t.team_id
LEFT JOIN agent AS a ON a.id = t.assigned_agent_id
WHERE t.status = 'open';
