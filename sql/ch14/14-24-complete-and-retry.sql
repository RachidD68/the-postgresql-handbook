-- Listing 14.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
UPDATE ticket_job
SET job_state = 'done', locked_by = NULL, locked_at = NULL
WHERE id = 1;

UPDATE ticket_job
SET job_state = 'queued',
    attempts  = attempts + 1,
    run_after = '2026-01-15 09:05:00+00',
    locked_by = NULL, locked_at = NULL
WHERE id = 2;

SELECT id, job_state, attempts FROM ticket_job WHERE id IN (1, 2) ORDER BY id;
