-- Listing 4.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference, priority, subject
FROM ticket
WHERE status = 'open'
ORDER BY reference;
