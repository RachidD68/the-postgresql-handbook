-- Listing 4.30 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference, priority, subject
FROM ticket
WHERE status = 'open'
ORDER BY CASE priority
             WHEN 'urgent' THEN 1
             WHEN 'high'   THEN 2
             WHEN 'normal' THEN 3
             ELSE 4
         END,
         created_at;
