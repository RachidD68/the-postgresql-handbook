-- Solution to Exercise 10.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 10 -Bulk
--              (80,040 tickets, 812 customers), then the index below.

-- Chapter 15 formalizes this index; here it is the experiment's variable:
CREATE INDEX ticket_customer_created_idx
    ON ticket (customer_id, created_at DESC);

-- Way 1: DISTINCT ON.
SELECT DISTINCT ON (customer_id)
       customer_id, reference, created_at
FROM ticket
ORDER BY customer_id, created_at DESC;

-- Way 2: LATERAL.
SELECT c.id, l.reference, l.created_at
FROM customer AS c
CROSS JOIN LATERAL (
    SELECT reference, created_at
    FROM ticket
    WHERE customer_id = c.id
    ORDER BY created_at DESC
    LIMIT 1
) AS l;

-- Way 3: ROW_NUMBER in a CTE.
WITH ranked AS (
    SELECT customer_id, reference, created_at,
           row_number() OVER (PARTITION BY customer_id
                              ORDER BY created_at DESC) AS rn
    FROM ticket
)
SELECT customer_id, reference, created_at
FROM ranked
WHERE rn = 1;

-- All three return the same 792 rows (20 of the 812 customers have no
-- tickets and appear in none of them).
--
-- Measured on the authoring machine (\timing, warm cache, median of 3):
--                     no index      with the index
--   DISTINCT ON        ~65 ms          ~56 ms
--   LATERAL         ~7,990 ms           ~4 ms
--   ROW_NUMBER         ~53 ms          ~56 ms
--
-- Plans with the index (EXPLAIN (COSTS OFF)):
--   DISTINCT ON: Unique -> Index Scan            (walks all 80,040 entries)
--   LATERAL:     Nested Loop -> 812 x (Limit -> Index Scan)  (one descent
--                per customer, one entry read each)
--   ROW_NUMBER:  Subquery Scan -> WindowAgg (Run Condition rn <= 1)
--                -> Index Scan                   (walks all 80,040 entries)
--
-- Readability ranking: DISTINCT ON wins (one line says "one per group"),
-- LATERAL second (the per-group query is explicit), ROW_NUMBER third
-- (mechanism before meaning). But only ROW_NUMBER generalizes to "most
-- recent TWO" while also handing you the position number: rn <= 2.
-- DISTINCT ON cannot say that at all; LATERAL says LIMIT 2 but numbers
-- nothing.
