-- Listing 13.2 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
SELECT reference, company_name, team, coalesce(agent, '(unassigned)') AS agent
FROM v_open_ticket
WHERE priority IN ('urgent', 'high')
ORDER BY reference;
