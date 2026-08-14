-- Solution to Exercise 7.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 7

-- The anti-join: the open-ticket condition rides in the ON (in the WHERE it
-- would undo the LEFT), and the IS NULL tests t.id — a column that cannot
-- be NULL on a real match.
SELECT a.id, a.full_name
FROM agent AS a
LEFT JOIN ticket AS t
    ON t.assigned_agent_id = a.id AND t.status = 'open'
WHERE t.id IS NULL
ORDER BY a.id;

-- Three idle-or-free agents: Sofia Ramos, Dmitri Volkov, Amara Diallo.
