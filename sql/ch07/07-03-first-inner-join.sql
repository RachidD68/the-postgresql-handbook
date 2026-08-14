-- Listing 7.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT t.reference, t.subject, c.full_name
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE t.status = 'open'
ORDER BY t.reference;
