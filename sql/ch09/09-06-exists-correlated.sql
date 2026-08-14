-- Listing 9.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT c.full_name, c.company_name
FROM customer AS c
WHERE EXISTS (SELECT *
              FROM ticket AS t
              WHERE t.customer_id = c.id AND t.status = 'open')
ORDER BY c.full_name;
