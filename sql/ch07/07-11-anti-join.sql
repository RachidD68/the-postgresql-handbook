-- Listing 7.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT c.full_name, c.company_name
FROM customer AS c
LEFT JOIN ticket AS t ON t.customer_id = c.id
WHERE t.id IS NULL;
