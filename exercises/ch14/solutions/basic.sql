-- Solution to Exercise 14.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 14
-- Leo Tanaka is agent 6, Marcus Webb agent 2; Leo holds 2 open tickets.

-- Counts before:
SELECT count(*) FILTER (WHERE assigned_agent_id = 6) AS leo_open,
       count(*) FILTER (WHERE assigned_agent_id = 2) AS marcus_open
FROM ticket
WHERE status = 'open';

-- THE SABOTAGE RUN: an error mid-transaction aborts everything.
BEGIN;
WITH moved AS (
    UPDATE ticket
    SET assigned_agent_id = 2
    WHERE assigned_agent_id = 6 AND status = 'open'
    RETURNING id
)
INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'reassigned',
       jsonb_build_object('from', 6, 'to', 2),
       '2026-01-15 09:00:00+00'
FROM moved;
SELECT 1 / 0;   -- the deliberate error
COMMIT;         -- psql reports ROLLBACK: the aborted transaction cannot commit

-- Counts after the sabotage: unchanged (2 and 2). Atomicity held.
SELECT count(*) FILTER (WHERE assigned_agent_id = 6) AS leo_open,
       count(*) FILTER (WHERE assigned_agent_id = 2) AS marcus_open
FROM ticket
WHERE status = 'open';

-- THE CLEAN RUN: same statements, no bomb.
BEGIN;
WITH moved AS (
    UPDATE ticket
    SET assigned_agent_id = 2
    WHERE assigned_agent_id = 6 AND status = 'open'
    RETURNING id
)
INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'reassigned',
       jsonb_build_object('from', 6, 'to', 2),
       '2026-01-15 09:00:00+00'
FROM moved;
COMMIT;

-- Counts after the clean run: 0 and 4, plus two audit events.
SELECT count(*) FILTER (WHERE assigned_agent_id = 6) AS leo_open,
       count(*) FILTER (WHERE assigned_agent_id = 2) AS marcus_open
FROM ticket
WHERE status = 'open';

SELECT count(*) AS reassigned_events
FROM ticket_event
WHERE event_kind = 'reassigned';
