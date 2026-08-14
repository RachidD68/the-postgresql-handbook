-- Solution to Exercise 23.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 23
--              (pgvector container, port 5433)

-- Fetch article 49's own embedding as the query vector:
SELECT embedding AS qv
FROM kb_article
WHERE id = 49 \gset

SELECT id, title,
       round((embedding <=> :'qv'::vector)::numeric, 4) AS distance
FROM kb_article
WHERE id <> 49
ORDER BY embedding <=> :'qv'::vector
LIMIT 5;

-- Why the exclusion matters: without WHERE id <> 49, rank 1 is always
-- article 49 itself at distance 0.0000 — an article is trivially nearest
-- to its own embedding, and "this article is related to itself" is a
-- slot wasted on something no user needs to be told.
