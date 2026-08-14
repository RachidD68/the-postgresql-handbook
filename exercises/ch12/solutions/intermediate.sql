-- Solution to Exercise 12.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 12

-- Way 1: the threshold spelled out in the WHERE.
SELECT full_name,
       round(similarity(full_name, 'Dimitri Volkof')::numeric, 3) AS score
FROM agent
WHERE similarity(full_name, 'Dimitri Volkof') > 0.35
ORDER BY score DESC;

-- Way 2: the threshold set once for the session, then the % operator.
SET pg_trgm.similarity_threshold = 0.35;

SELECT full_name,
       round(similarity(full_name, 'Dimitri Volkof')::numeric, 3) AS score
FROM agent
WHERE full_name % 'Dimitri Volkof'
ORDER BY score DESC;

RESET pg_trgm.similarity_threshold;

-- Both return exactly one agent: Dmitri Volkov, comfortably clear of the
-- bar. The WHERE version is explicit per query; the SET version is what an
-- application configures once at connection time — and it is also what the
-- trigram INDEX path uses, since % is indexable and similarity() > x is not.
