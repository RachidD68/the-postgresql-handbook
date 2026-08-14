-- Solution to Exercise 7.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 7

-- The reading, before running: grain is one row per AGENT-AUTHORED REPLY
-- (a comment with a parent, authored by an agent). Prediction: every
-- assigned ticket's thread has exactly one agent reply and the two
-- unassigned tickets have none, so 38 rows.
SELECT reply.id AS reply_id, opener.id AS opener_id, a.full_name
FROM ticket_comment AS reply
JOIN ticket_comment AS opener ON opener.id = reply.parent_comment_id
JOIN agent AS a
    ON a.id = reply.author_id AND reply.author_kind = 'agent'
ORDER BY reply.id;

-- 38 rows — the prediction holds (38 assigned tickets, one agent reply each).
--
-- The author_kind condition: with all-inner joins, ON and WHERE placement
-- produce identical results, so both positions work HERE. It still belongs
-- in the ON — it is part of what makes the agent join a match, and the query
-- survives the day someone softens a join to LEFT.
