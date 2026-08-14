-- Solution to Exercise 14.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 14,
--              then sql/ch14/14-19-the-queue-table.sql (the chapter's queue).

-- CLAIM: its own transaction, committed before any work happens.
BEGIN;
WITH claimed AS (
    UPDATE ticket_job
    SET job_state = 'running',
        locked_at = '2026-01-15 09:00:00+00',
        locked_by = 'worker-d'
    WHERE id IN (SELECT id
                 FROM ticket_job
                 WHERE job_state = 'queued'
                   AND run_after <= '2026-01-15 09:00:00+00'
                 ORDER BY id
                 FOR UPDATE SKIP LOCKED
                 LIMIT 3)
    RETURNING id, job_kind
)
SELECT id, job_kind FROM claimed ORDER BY id;
-- Claims jobs 1, 2, 3 — all fifty seed jobs have run_after at or before
-- the anchor, so the three lowest ids win.
COMMIT;

-- WORK: simulated.
SELECT pg_sleep(0.1);

-- COMPLETE: two done, one failed and re-queued ten minutes out.
UPDATE ticket_job
SET job_state = 'done', locked_by = NULL, locked_at = NULL
WHERE id IN (1, 2);

UPDATE ticket_job
SET job_state = 'queued',
    attempts  = attempts + 1,
    run_after = '2026-01-15 09:10:00+00',
    locked_by = NULL, locked_at = NULL
WHERE id = 3;

SELECT id, job_state, attempts, run_after
FROM ticket_job
WHERE id IN (1, 2, 3)
ORDER BY id;

-- Why the claim must commit before the work: holding the claim transaction
-- open for the whole job means the row locks — and the transaction's xid,
-- which pins vacuum — live as long as the work does, and a crash mid-work
-- silently returns the jobs to every other worker at once. Claim-then-commit
-- makes the claim durable and visible in milliseconds.
--
-- The sweep that decision obliges: a crash now leaves jobs marked 'running'
-- forever, so a janitor must re-queue staleness on a schedule:
--   UPDATE ticket_job
--   SET job_state = 'queued', attempts = attempts + 1,
--       locked_by = NULL, locked_at = NULL
--   WHERE job_state = 'running'
--     AND locked_at < now() - interval '10 minutes';
