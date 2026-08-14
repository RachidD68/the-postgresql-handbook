-- Listing 14.22 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
BEGIN;
SELECT id FROM ticket_job
WHERE job_state = 'queued'
ORDER BY id
FOR UPDATE SKIP LOCKED
LIMIT 2;

-- [B]
BEGIN;
SELECT id FROM ticket_job
WHERE job_state = 'queued'
ORDER BY id
FOR UPDATE SKIP LOCKED
LIMIT 2;

-- [A]
ROLLBACK;

-- [B]
ROLLBACK;
