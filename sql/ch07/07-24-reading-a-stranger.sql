-- Listing 7.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT a.full_name, t.reference, t.resolution_minutes
FROM agent AS a
JOIN ticket AS t
  ON t.assigned_agent_id = a.id
 AND t.resolution_minutes IS NOT NULL
JOIN customer AS c
  ON c.id = t.customer_id AND c.plan = 'enterprise'
ORDER BY t.resolution_minutes DESC;
