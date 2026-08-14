-- Listing 4.33 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference,
       resolved_at - created_at AS time_to_resolve,
       round(EXTRACT(EPOCH FROM resolved_at - created_at) / 3600, 1) AS hours
FROM ticket
WHERE resolved_at IS NOT NULL
ORDER BY time_to_resolve DESC
LIMIT 5;
