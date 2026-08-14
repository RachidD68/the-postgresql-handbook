-- Solution to Exercise 4.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 4

-- Filter first, deduplicate second: WHERE runs before DISTINCT ON picks
-- each customer's winner.
SELECT DISTINCT ON (customer_id)
       customer_id, reference, created_at
FROM ticket
WHERE status IN ('open', 'waiting_on_customer')
ORDER BY customer_id, created_at DESC;

-- Eleven rows (customer 3 has nothing open or waiting). Reading the grid:
-- customer 9's LUM-1028 is the oldest at 2025-12-22 — Chapter 2's most
-- neglected ticket, parked in waiting_on_customer since December, which is
-- exactly why it (not an open ticket) marks the longest wait.
