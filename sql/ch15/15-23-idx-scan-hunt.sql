-- Listing 15.23 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
SELECT indexrelname AS never_scanned
FROM pg_stat_user_indexes
WHERE schemaname = 'lumina' AND relname = 'ticket' AND idx_scan = 0
ORDER BY indexrelname;
