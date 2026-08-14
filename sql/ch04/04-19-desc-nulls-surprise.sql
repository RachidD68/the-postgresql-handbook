-- Listing 4.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference, satisfaction
FROM ticket
WHERE status = 'closed' AND team_id = 2
ORDER BY satisfaction DESC;
