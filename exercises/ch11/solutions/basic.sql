-- Solution to Exercise 11.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 11

-- Containment: the version to ship.
SELECT t.reference, t.subject
FROM ticket AS t
JOIN ticket_event AS e ON e.ticket_id = t.id
WHERE e.event_kind = 'created'
  AND e.payload @> '{"channel": "email"}'
ORDER BY t.created_at;

-- The same filter with the arrow:
SELECT t.reference, t.subject
FROM ticket AS t
JOIN ticket_event AS e ON e.ticket_id = t.id
WHERE e.event_kind = 'created'
  AND e.payload ->> 'channel' = 'email'
ORDER BY t.created_at;

-- Both return the same 19 tickets, LUM-1001 (2025-11-03) first. Ship the
-- containment version: @> is what Chapter 15's GIN index accelerates — the
-- arrows, by default, are not.
