-- Listing 14.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
CREATE TABLE ticket_job (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_kind   text NOT NULL,
    payload    jsonb NOT NULL DEFAULT '{}',
    job_state  text NOT NULL DEFAULT 'queued'
        CONSTRAINT job_state_check
        CHECK (job_state IN ('queued', 'running', 'done', 'failed')),
    attempts   int NOT NULL DEFAULT 0,
    run_after  timestamptz NOT NULL,
    locked_at  timestamptz,
    locked_by  text
);

INSERT INTO ticket_job (job_kind, payload, run_after)
SELECT CASE n % 3
           WHEN 0 THEN 'email_customer'
           WHEN 1 THEN 'recompute_stats'
           ELSE 'webhook_push'
       END,
       jsonb_build_object('ticket_id', (n % 40) + 1),
       '2026-01-15 08:00:00+00'::timestamptz + (n % 7) * interval '10 minutes'
FROM generate_series(1, 50) AS n;
