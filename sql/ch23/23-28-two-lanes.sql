-- Listing 23.28 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
-- The lexical lane needs its own index: the HNSW's counterpart.
CREATE INDEX IF NOT EXISTS kb_article_search_idx
    ON kb_article USING gin (search_tsv);

SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

-- Lane 1, Chapter 12's machinery: the query's WORDS
SELECT id, title,
       round(ts_rank(search_tsv,
                     websearch_to_tsquery('english', 'printer'))::numeric, 2) AS rank
FROM kb_article
WHERE search_tsv @@ websearch_to_tsquery('english', 'printer')
ORDER BY ts_rank(search_tsv, websearch_to_tsquery('english', 'printer')) DESC, id
LIMIT 5;

-- Lane 2, this chapter's machinery: the query's MEANING
SELECT id, title,
       round((embedding <=> :'qv'::vector)::numeric, 2) AS distance
FROM kb_article
ORDER BY embedding <=> :'qv'::vector
LIMIT 5;
