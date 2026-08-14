-- Listing 10.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT customer_id FROM ticket WHERE status = 'open'
UNION
SELECT customer_id FROM ticket WHERE priority = 'urgent'
ORDER BY customer_id;
