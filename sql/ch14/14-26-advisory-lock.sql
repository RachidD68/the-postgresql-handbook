-- Listing 14.26 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
SELECT pg_try_advisory_lock(hashtext('recompute-customer-2')) AS got_it;

-- [B]
SELECT pg_try_advisory_lock(hashtext('recompute-customer-2')) AS got_it;

-- [A]
SELECT pg_advisory_unlock(hashtext('recompute-customer-2')) AS released;

-- [B]
SELECT pg_try_advisory_lock(hashtext('recompute-customer-2')) AS got_it;

-- [B]
SELECT pg_advisory_unlock(hashtext('recompute-customer-2')) AS released;
