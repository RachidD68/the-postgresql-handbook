-- Listing 6.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
SELECT reference, resolution_minutes
FROM ticket
WHERE resolution_minutes IS NOT NULL
ORDER BY resolution_minutes DESC
LIMIT 5;
