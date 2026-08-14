-- Listing 18.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
-- postgresql.conf (or the compose file's command:), then restart:
--   shared_preload_libraries = 'pg_stat_statements'

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT calls, rows, left(query, 60) AS query_shape
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;
