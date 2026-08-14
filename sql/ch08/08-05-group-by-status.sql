-- Listing 8.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT status, count(*) AS tickets
FROM ticket
GROUP BY status
ORDER BY tickets DESC, status;
