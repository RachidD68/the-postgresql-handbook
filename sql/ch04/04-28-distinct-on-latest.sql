-- Listing 4.28 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT DISTINCT ON (customer_id)
       customer_id, reference, created_at
FROM ticket
ORDER BY customer_id, created_at DESC;
