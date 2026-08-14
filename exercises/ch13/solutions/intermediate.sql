-- Solution to Exercise 13.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 13
--
-- Note: the exercise text says RETURNS TABLE (status ticket_status, ...),
-- but ticket.status is deliberately text (Chapter 5 guarded priority with
-- an enum and left status to Chapter 6's CHECK) — so the honest signature
-- returns text.

CREATE FUNCTION fn_customer_status_counts(c_id bigint)
RETURNS TABLE (status text, tickets bigint)
LANGUAGE sql
AS $$
    SELECT status, count(*)
    FROM ticket
    WHERE customer_id = c_id
    GROUP BY status
    ORDER BY status;
$$;

-- Plain call for customer 2 (Northwind Traders):
SELECT * FROM fn_customer_status_counts(2);

-- Laterally, for all enterprise customers:
SELECT c.company_name, s.status, s.tickets
FROM customer AS c
CROSS JOIN LATERAL fn_customer_status_counts(c.id) AS s
WHERE c.plan = 'enterprise'
ORDER BY c.company_name, s.status;
