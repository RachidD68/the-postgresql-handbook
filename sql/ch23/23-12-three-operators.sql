-- Listing 23.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
WITH feeder AS (
    SELECT embedding
    FROM kb_article
    WHERE title LIKE 'Document feeder%'
    ORDER BY id LIMIT 1
), spooler AS (
    SELECT embedding
    FROM kb_article
    WHERE title LIKE 'Print jobs stall%'
    ORDER BY id LIMIT 1
)
SELECT round((f.embedding <=> s.embedding)::numeric, 4) AS cosine,
       round((f.embedding <-> s.embedding)::numeric, 4) AS euclidean,
       round((f.embedding <#> s.embedding)::numeric, 4) AS neg_inner
FROM feeder AS f, spooler AS s;
