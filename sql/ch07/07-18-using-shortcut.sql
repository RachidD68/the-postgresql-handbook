-- Listing 7.18 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT t.reference, a.full_name AS could_take_it
FROM ticket AS t
JOIN agent AS a USING (team_id)
WHERE t.reference = 'LUM-1036'
ORDER BY a.id;
