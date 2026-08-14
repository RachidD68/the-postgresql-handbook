-- Listing 4.25 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference, subject, created_at
FROM ticket
ORDER BY created_at DESC
LIMIT 5 OFFSET 5;
