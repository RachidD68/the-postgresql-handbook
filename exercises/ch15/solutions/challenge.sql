-- Solution to Exercise 15.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 15

-- The audit, with the trio built so the numbers are real:
CREATE INDEX t1 ON ticket (team_id);                        -- 560 kB
CREATE INDEX t2 ON ticket (team_id, priority);              -- 568 kB
CREATE INDEX t3 ON ticket (team_id, priority, created_at);  -- 3200 kB

SELECT pg_size_pretty(pg_relation_size('t1')) AS team_only,
       pg_size_pretty(pg_relation_size('t2')) AS team_priority,
       pg_size_pretty(pg_relation_size('t3')) AS team_priority_created;

-- Redundancies: (team_id) is a leftmost prefix of (team_id, priority),
-- which is a leftmost prefix of the third — two of the three are shadows.
-- Keep the widest; the survivor serves all three question shapes:
DROP INDEX t1, t2;

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE team_id = 2;
--  Aggregate -> Index Only Scan using t3 on ticket
--                 Index Cond: (team_id = 2)

-- The shape the survivor serves strictly worse: a query pinning ONLY
-- team_id now reads a 3200 kB index where 560 kB would do — same tree
-- walk, more pages per range scan. Whether that regression justifies a
-- second index is a Chapter 16 measurement, not an opinion; the honest
-- default is one index until the numbers complain.
