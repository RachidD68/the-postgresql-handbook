-- Listing 16.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT c.company_name, count(*)
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
GROUP BY c.company_name;
