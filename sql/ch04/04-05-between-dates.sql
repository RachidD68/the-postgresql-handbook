-- Listing 4.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference, subject, created_at
FROM ticket
WHERE created_at BETWEEN '2026-01-12' AND '2026-01-15'
ORDER BY created_at;
