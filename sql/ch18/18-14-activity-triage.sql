-- Listing 18.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
SELECT pid, state, wait_event_type,
       pg_blocking_pids(pid) AS blocked_by,
       left(query, 40) AS running
FROM pg_stat_activity
WHERE state <> 'idle' AND pid <> pg_backend_pid()
ORDER BY pid;
