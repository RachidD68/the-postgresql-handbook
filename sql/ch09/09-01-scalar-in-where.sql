-- Listing 9.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT reference, resolution_minutes
FROM ticket
WHERE resolution_minutes >
      (SELECT avg(resolution_minutes) FROM ticket)
ORDER BY resolution_minutes DESC;
