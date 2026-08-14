-- Solution to Exercise 3.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 3

-- Step 1: SELECT with the intended WHERE. Northwind Traders is customer 2 —
-- the id, not the name, belongs in the WHERE.
SELECT id, reference, status
FROM ticket
WHERE customer_id = 2 AND status = 'closed';
-- One row: LUM-1012. Note the count: 1.

-- Step 2: the UPDATE with the identical WHERE.
UPDATE ticket
SET status = 'open'
WHERE customer_id = 2 AND status = 'closed';
-- Command tag: UPDATE 1.

-- Step 3: compare. SELECT saw 1 row; UPDATE touched 1 row. Match.
--
-- A mismatch would mean the data changed between the two statements —
-- another writer got there first. Chapter 14 names the phenomenon (a race
-- under READ COMMITTED) and supplies the cure (one transaction, or
-- SELECT ... FOR UPDATE).
