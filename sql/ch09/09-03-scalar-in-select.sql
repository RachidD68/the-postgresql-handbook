-- Listing 9.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT reference,
       resolution_minutes,
       round(resolution_minutes -
             (SELECT avg(resolution_minutes) FROM ticket), 0) AS vs_average
FROM ticket
WHERE resolution_minutes IS NOT NULL
ORDER BY vs_average DESC
LIMIT 5;
