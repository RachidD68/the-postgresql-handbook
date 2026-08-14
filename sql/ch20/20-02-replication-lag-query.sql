-- Listing 20.2 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch20/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 20
SELECT application_name, state,
       write_lag, flush_lag, replay_lag
FROM pg_stat_replication;
