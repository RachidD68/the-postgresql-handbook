-- Solution to Exercise 16.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 16

EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT * FROM v_open_ticket WHERE priority = 'urgent';

-- The four sentences (plan on the authoring machine, 80,040 tickets):
--
-- 1. The view inlined into a four-table join: ticket got an Index Scan on
--    ticket_open_created_idx (the partial open-ticket index — the view's
--    WHERE status = 'open' matches its predicate), customer a Seq Scan
--    into a Hash, team and agent Index Scans on their primary keys.
-- 2. The join algorithms split by size: customer (812 rows) was hashed
--    once, while team and agent sit behind Nested Loops with Memoize —
--    121 driving rows against caches that missed only 2 and 3 times.
-- 3. The priority filter was applied at the ticket scan itself
--    (Filter: priority = 'urgent', Rows Removed: 6,426) — the earliest
--    possible moment, before any join saw a row.
-- 4. The choices are arithmetic: 121 urgent-open tickets drive cheap
--    memoized lookups into three- and thirty-row tables, and hashing the
--    812-row customer table once beats 121 index descents into it.
