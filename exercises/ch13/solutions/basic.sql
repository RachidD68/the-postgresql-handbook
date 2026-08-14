-- Solution to Exercise 13.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 13

CREATE VIEW v_unassigned_ticket AS
SELECT t.reference, t.subject, tm.name AS team, t.priority, t.created_at
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
WHERE t.status = 'open'
  AND t.assigned_agent_id IS NULL
ORDER BY t.created_at;

SELECT * FROM v_unassigned_ticket;
-- Two rows: LUM-1036 and LUM-1039, oldest first.

-- Why no LEFT JOIN is safe here: v_open_ticket LEFT-joins agent to keep
-- open tickets that have no agent. This view keeps ONLY agentless tickets —
-- there is no agent column to preserve, so the join it does not perform
-- cannot drop anything it wants to keep. (The team join is an inner join
-- to a NOT NULL FK: it can never lose a row either.)
