-- Solution to Exercise 23.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 23
--              (pgvector container, port 5433)
--
-- Listing 23.28 with ONE change: the lexical lane's contribution becomes
-- 2.0 / (60 + rank). Query vectors follow the fixture convention (borrow
-- the stored embedding of the article nearest the query's topic — the
-- FixtureEmbedder's rule). Repeat the pair below for each query by
-- swapping the two \set lines.

-- ── Query 1: 'printer' (qv anchor: the document-feeder article) ──────
\set lexterm 'printer'
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

-- Weighted fusion (the unweighted original is listing 23.30 verbatim):
WITH vector_hits AS (
    SELECT id, title,
           row_number() OVER (ORDER BY embedding <=> :'qv'::vector, id) AS rank
    FROM kb_article
    ORDER BY embedding <=> :'qv'::vector, id
    LIMIT 20
), lexical_hits AS (
    SELECT id, title,
           row_number() OVER (
               ORDER BY ts_rank(search_tsv,
                                websearch_to_tsquery('english', :'lexterm')) DESC, id
           ) AS rank
    FROM kb_article
    WHERE search_tsv @@ websearch_to_tsquery('english', :'lexterm')
    ORDER BY ts_rank(search_tsv,
                     websearch_to_tsquery('english', :'lexterm')) DESC, id
    LIMIT 20
)
SELECT coalesce(v.title, l.title) AS title,
       round((coalesce(1.0 / (60 + v.rank), 0)
            + coalesce(2.0 / (60 + l.rank), 0))::numeric, 5) AS rrf_score
FROM vector_hits AS v
FULL OUTER JOIN lexical_hits AS l USING (id)
ORDER BY rrf_score DESC, id
LIMIT 5;

-- ── Query 2: 'DKIM' (qv anchor: the outbound-email article) ──────────
-- \set lexterm 'DKIM'   + qv from title LIKE 'Outbound email%'

-- ── Query 3: 'slow dashboard' (qv anchor: the dashboard-lag article) ─
-- \set lexterm 'slow dashboard'   + qv from title LIKE 'Dashboard lags%'

-- FINDINGS (real runs, container State 23; top five per query):
--
-- 'printer' — the same five consensus titles hold the top five in both
-- versions; what changes is their ORDER, which now follows lexical rank
-- (the jams article ranked 1st by words jumps from 2nd to 1st). The
-- vector-only feeder and spooler articles sit just below the top five in
-- both versions and slide, not fall: a lane's whole contribution is
-- bounded (2/61 at best), so RRF degrades gracefully.
--
-- 'slow dashboard' — top four are consensus rows and reorder mildly
-- toward lexical preference; slot five is a LEXICAL-ONLY row (rank 1 by
-- words, absent from the vector lane's top 20) whose score exactly
-- doubles (0.01639 to 0.03279) yet stays fifth — doubling a single
-- lane's vote still does not beat two lanes agreeing.
--
-- 'DKIM' — barely moves: the top three are identical and only the 4/5
-- pair swaps. Every DKIM hit is an email-deliverability article BOTH
-- lanes already ranked highly, so doubling the lexical vote multiplies a
-- consensus that was already deciding the order. Weighting a consensus
-- changes little — which is itself the finding worth writing down.
