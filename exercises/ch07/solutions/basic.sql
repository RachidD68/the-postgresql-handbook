-- Solution to Exercise 7.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 7

-- Chapter 5's enum means ORDER BY priority DESC is now urgency order —
-- the CASE workaround retired.
SELECT t.reference, t.priority,
       c.full_name AS customer,
       tm.name AS team
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
JOIN team AS tm ON tm.id = t.team_id
WHERE t.status = 'open'
ORDER BY t.priority DESC, t.created_at;

-- Seven rows in, seven rows out. The chain cannot fan out because both
-- joins walk toward the arrow's ONE side: a ticket has exactly one
-- customer and one team, so the grain stays one-row-per-ticket.
