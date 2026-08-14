-- Listing 23.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
CREATE INDEX IF NOT EXISTS kb_article_metadata_gin
    ON kb_article USING gin (metadata);

SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

SELECT title,
       round((embedding <=> :'qv'::vector)::numeric, 4) AS distance
FROM kb_article
WHERE metadata @> '{"area": "printer", "verified": true}'
ORDER BY embedding <=> :'qv'::vector
LIMIT 5;
