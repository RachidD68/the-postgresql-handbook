-- Listing 13.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE UNIQUE INDEX mv_monthly_stats_month_idx
    ON mv_monthly_stats (month_of);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_stats;
