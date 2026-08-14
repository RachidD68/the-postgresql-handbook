-- Listing 14.20 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
WITH claimed AS (
    UPDATE ticket_job
    SET job_state = 'running',
        locked_at = '2026-01-15 09:00:00+00',
        locked_by = 'worker-1'
    WHERE id IN (SELECT id
                 FROM ticket_job
                 WHERE job_state = 'queued'
                   AND run_after <= '2026-01-15 09:00:00+00'
                 ORDER BY id
                 FOR UPDATE SKIP LOCKED
                 LIMIT 5)
    RETURNING id, job_kind
)
SELECT id, job_kind FROM claimed ORDER BY id;
