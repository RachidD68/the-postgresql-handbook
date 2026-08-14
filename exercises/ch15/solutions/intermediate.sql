-- Solution to Exercise 15.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 15

-- Predicate = the screen's filter; key = its ordering; INCLUDE = its columns.
CREATE INDEX ticket_triage_idx
    ON ticket (created_at)
    INCLUDE (reference, priority)
    WHERE status = 'open' AND assigned_agent_id IS NULL;

VACUUM (ANALYZE) ticket;   -- freshen the visibility map for index-only scans

EXPLAIN (COSTS OFF)
SELECT reference, priority, created_at
FROM ticket
WHERE status = 'open' AND assigned_agent_id IS NULL
ORDER BY created_at;
--  Index Only Scan using ticket_triage_idx on ticket
-- One line: no filter, no sort, no heap — the index IS the screen.

SELECT pg_size_pretty(pg_relation_size('ticket_triage_idx'));
-- 56 kB, indexing exactly the 862-row queue — against the 1768 kB
-- full-column index from listing 15.13: 31 times smaller.
