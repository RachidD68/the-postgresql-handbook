-- Solution to Exercise 15.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 15

CREATE INDEX ticket_channel_idx ON ticket (channel);

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE channel = 'phone';
--  Aggregate
--    ->  Index Only Scan using ticket_channel_idx on ticket
--          Index Cond: (channel = 'phone'::text)

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE channel = 'email';

-- The arithmetic: phone is 8,002 of 80,040 tickets (10%), email 32,019
-- (40%). An index earns its keep by excluding most of the table, so a 40%
-- filter is a legitimate candidate for a sequential scan. On the book's
-- pinned settings (random_page_cost = 1.1) the pure count stays an Index
-- Only Scan for both — counting never touches the heap, so selectivity
-- barely matters. Make the query fetch rows under honest disk costs and
-- the 40% filter drifts off the plain index path:
--   SET random_page_cost = 4;
--   EXPLAIN (COSTS OFF) SELECT reference, subject FROM ticket
--   WHERE channel = 'email';
--   ->  Bitmap Heap Scan on ticket  (no longer a plain index scan)
-- Not a malfunction — arithmetic. Chapter 16 makes it visible.
