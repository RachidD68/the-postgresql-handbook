-- Listing 23.30 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

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
                                websearch_to_tsquery('english', 'printer')) DESC, id
           ) AS rank
    FROM kb_article
    WHERE search_tsv @@ websearch_to_tsquery('english', 'printer')
    ORDER BY ts_rank(search_tsv,
                     websearch_to_tsquery('english', 'printer')) DESC, id
    LIMIT 20
)
SELECT coalesce(v.title, l.title) AS title,
       round((coalesce(1.0 / (60 + v.rank), 0)
            + coalesce(1.0 / (60 + l.rank), 0))::numeric, 5) AS rrf_score
FROM vector_hits AS v
FULL OUTER JOIN lexical_hits AS l USING (id)
ORDER BY rrf_score DESC, id
LIMIT 8;
