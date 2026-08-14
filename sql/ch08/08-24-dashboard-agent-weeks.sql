-- Listing 8.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT a.full_name AS agent,
       date_trunc('week', t.created_at)::date AS week_of,
       count(*) AS tickets
FROM ticket AS t
JOIN agent AS a ON a.id = t.assigned_agent_id
WHERE t.created_at >= '2025-12-15 00:00:00+00'
GROUP BY a.full_name, week_of
ORDER BY week_of, tickets DESC, agent;
