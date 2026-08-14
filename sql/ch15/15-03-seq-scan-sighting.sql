-- Listing 15.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE customer_id = 507;
