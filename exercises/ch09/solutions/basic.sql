-- Solution to Exercise 9.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 9

-- Tickets whose customer is on the enterprise plan (no join):
SELECT t.reference, t.subject
FROM ticket AS t
WHERE EXISTS (SELECT *
              FROM customer AS c
              WHERE c.id = t.customer_id AND c.plan = 'enterprise')
ORDER BY t.reference;
-- 14 rows, LUM-1001 first.

-- Flipped: customers who have never filed an urgent ticket.
SELECT c.full_name, c.company_name
FROM customer AS c
WHERE NOT EXISTS (SELECT *
                  FROM ticket AS t
                  WHERE t.customer_id = c.id AND t.priority = 'urgent')
ORDER BY c.full_name;
-- 7 of the 12 customers.

-- Why NOT IN would have been dangerous: NOT IN returns no rows the moment
-- the subquery's set contains a single NULL. ticket.customer_id happens to
-- be NOT NULL, so it would work today — safety by luck, and one nullable
-- column away from an empty report.
