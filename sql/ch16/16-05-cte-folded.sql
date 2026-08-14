-- Listing 16.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (COSTS OFF)
WITH one_customer AS (
    SELECT * FROM ticket WHERE customer_id = 507
)
SELECT count(*) FROM one_customer;
