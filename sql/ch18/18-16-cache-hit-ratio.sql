-- Listing 18.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
SELECT datname,
       round(100.0 * blks_hit / nullif(blks_hit + blks_read, 0), 2)
           AS cache_hit_pct,
       xact_commit, deadlocks
FROM pg_stat_database
WHERE datname = 'lumina';
