-- Listing 23.23 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

WITH ranked AS (
    SELECT title, embedding <=> :'qv'::vector AS dist,
           row_number() OVER (ORDER BY embedding <=> :'qv'::vector) AS rank
    FROM kb_article
)
SELECT rank, title, round(dist::numeric, 3) AS distance
FROM ranked
WHERE rank IN (1, 2, 8, 40, 200)
ORDER BY rank;
