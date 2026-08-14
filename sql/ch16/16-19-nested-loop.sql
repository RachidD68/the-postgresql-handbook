-- Listing 16.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT t.reference, c.company_name
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE c.id = 507;
