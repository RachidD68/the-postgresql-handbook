-- Listing 23.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

SHOW hnsw.ef_search;

SET hnsw.ef_search = 100;

SELECT id, title
FROM kb_article
ORDER BY embedding <=> :'qv'::vector
LIMIT 3;
