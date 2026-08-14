-- Listing 16.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE customer_id = 507;
