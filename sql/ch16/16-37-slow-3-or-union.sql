-- Listing 16.37 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT t.reference
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE t.reference = 'LUM-50000' OR c.company_name = 'Company 042';

EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT t.reference FROM ticket AS t
WHERE t.reference = 'LUM-50000'
UNION
SELECT t.reference
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE c.company_name = 'Company 042';
