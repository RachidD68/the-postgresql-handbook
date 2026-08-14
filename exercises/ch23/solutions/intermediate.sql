-- Solution to Exercise 23.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 23
--              (pgvector container, port 5433)

-- The scanner question's query vector, exactly as §5 obtained it:
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

-- Semantic search, restricted to articles distilled from team 1's tickets:
SELECT kb.id, kb.title,
       round((kb.embedding <=> :'qv'::vector)::numeric, 3) AS distance
FROM kb_article AS kb
JOIN ticket AS t ON t.id = kb.ticket_id
WHERE t.team_id = 1
ORDER BY kb.embedding <=> :'qv'::vector
LIMIT 5;

-- What happened to the query's shape: almost nothing — a Chapter 7 join
-- and a WHERE slid in beside the ORDER BY ... LIMIT, and metadata
-- filtering composed with ANN search in one statement. That is §1's
-- promised payoff: no second system, no post-filtering dance.
--
-- The inner join also quietly dropped every article whose ticket_id is
-- NULL (general knowledge distilled from no ticket). Decide whether that
-- is a feature before your users decide for you — a LEFT JOIN with
-- "t.team_id = 1 OR kb.ticket_id IS NULL" is the other defensible answer.
