-- Listing 7.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT tm.name AS team, s.applies_to_priority, s.first_response_minutes
FROM team AS tm
CROSS JOIN sla_policy AS s
ORDER BY tm.id, s.id;
