-- Solution to Exercise 16.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 16

-- The original (measured 49.5 ms on the authoring machine):
EXPLAIN ANALYZE
SELECT count(*) FROM ticket WHERE upper(channel) = 'PHONE';
--  Seq Scan, Filter: upper(channel) = 'PHONE', Rows Removed: 72038
--  ... and rows=400 ESTIMATED vs 8,002 actual: the planner has no
--  statistics on an expression, so it guesses.

-- Cure 1 — the rewrite (35.4 ms): the column is already lowercase.
EXPLAIN ANALYZE
SELECT count(*) FROM ticket WHERE channel = 'phone';
--  Still a Seq Scan, but no function call per row — and the estimate
--  (8,084) is nearly exact, because the column has real statistics.

-- Cure 2 — the expression index the original spelling wants (4.0 ms):
CREATE INDEX ticket_channel_upper_idx ON ticket (upper(channel));

EXPLAIN ANALYZE
SELECT count(*) FROM ticket WHERE upper(channel) = 'PHONE';
--  Bitmap Heap Scan <- Bitmap Index Scan on ticket_channel_upper_idx

-- Ship the rewrite. The expression index is faster today, but it buys
-- speed for a query that never needed a function, at the price of an
-- index maintained on every write — carry it only when you cannot change
-- the caller. (If the report is hot, the rewrite plus Chapter 15's plain
-- channel index gets the same speed without the upper() debt.)
