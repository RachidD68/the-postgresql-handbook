-- Listing 23.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

SELECT id, title,
       round((embedding <=> :'qv'::vector)::numeric, 3) AS distance
FROM kb_article
WHERE title NOT LIKE 'Document feeder%'
ORDER BY embedding <=> :'qv'::vector
LIMIT 5;
