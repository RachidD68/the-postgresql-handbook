-- Solution to Exercise 19.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 19,
--              then sql/ch19/19-01, 19-02, 19-03, and the 2026_03 partition
--              from listing 19-13 (the chapter's own partitioning work).

BEGIN;

INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
VALUES (1, 'routing_demo', '{}', '2026-03-15 12:00:00+00'),
       (1, 'routing_demo', '{}', '2027-01-01 00:00:00+00');

SELECT tableoid::regclass AS landed_in, occurred_at
FROM ticket_event
WHERE event_kind = 'routing_demo'
ORDER BY occurred_at;
--        landed_in       |      occurred_at
--  ticket_event_2026_03  | 2026-03-15 12:00:00+00
--  ticket_event_default  | 2027-01-01 00:00:00+00

ROLLBACK;

-- The March row routed to its month. The 2027 row was ROUTED, not
-- rejected: it is now a squatter in DEFAULT, and as long as it sits there
-- every one-sided date query must scan DEFAULT too — the conveyor
-- discipline failed silently, which is exactly what the chapter's
-- DEFAULT-count health check exists to page you about.
