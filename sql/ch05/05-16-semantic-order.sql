-- Listing 5.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
SELECT reference, priority, subject
FROM ticket
WHERE status = 'open'
ORDER BY priority DESC, created_at;
