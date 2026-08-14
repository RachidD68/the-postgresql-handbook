-- Listing 23.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

SELECT id, title,
       round((embedding <=> :'qv'::vector)::numeric, 4) AS distance
FROM kb_article
ORDER BY embedding <=> :'qv'::vector
LIMIT 5;
