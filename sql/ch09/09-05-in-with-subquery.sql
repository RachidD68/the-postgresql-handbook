-- Listing 9.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT full_name, company_name
FROM customer
WHERE id IN (SELECT customer_id FROM ticket WHERE status = 'open')
ORDER BY full_name;
