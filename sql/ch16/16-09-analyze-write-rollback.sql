-- Listing 16.9 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
BEGIN;

EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
UPDATE ticket SET priority = 'high'
WHERE assigned_agent_id = 105 AND status = 'open';

ROLLBACK;
