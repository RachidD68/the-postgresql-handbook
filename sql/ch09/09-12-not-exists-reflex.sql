-- Listing 9.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT a.full_name
FROM agent AS a
WHERE NOT EXISTS (SELECT *
                  FROM ticket AS t
                  WHERE t.assigned_agent_id = a.id);
