-- Listing 17.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
GRANT SELECT ON v_open_ticket, v_agent_workload TO lumina_readonly;

SET ROLE lumina_readonly;
SELECT reference, team, priority FROM v_open_ticket
ORDER BY reference LIMIT 3;

RESET ROLE;
