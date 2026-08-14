-- Listing 11.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT jsonb_pretty(to_jsonb(tm)) AS team_as_document
FROM team AS tm
WHERE tm.id = 3
ORDER BY tm.id;
