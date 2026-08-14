-- Listing 15.25 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
SELECT indexname,
       pg_size_pretty(pg_relation_size(indexname::regclass)) AS on_disk
FROM pg_indexes
WHERE schemaname = 'lumina' AND tablename = 'ticket'
  AND indexdef LIKE '%assigned_agent_id%'
ORDER BY indexname;
