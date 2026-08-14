-- Listing 18.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
CREATE TABLE vac_scratch AS SELECT * FROM ticket;

UPDATE vac_scratch SET priority = priority;

SELECT pg_stat_force_next_flush();
SELECT n_live_tup, n_dead_tup,
       pg_size_pretty(pg_relation_size('vac_scratch')) AS on_disk
FROM pg_stat_user_tables WHERE relname = 'vac_scratch';
