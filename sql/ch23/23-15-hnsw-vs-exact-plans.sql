-- Listing 23.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
EXPLAIN (COSTS OFF)
SELECT id, title
FROM kb_article
ORDER BY embedding <=> (SELECT embedding
                        FROM kb_article
                        WHERE title LIKE 'Document feeder%'
                        ORDER BY id LIMIT 1)
LIMIT 5;

SET enable_seqscan = off;  -- diagnostic only: force the index to SEE it

EXPLAIN (COSTS OFF)
SELECT id, title
FROM kb_article
ORDER BY embedding <=> (SELECT embedding
                        FROM kb_article
                        WHERE title LIKE 'Document feeder%'
                        ORDER BY id LIMIT 1)
LIMIT 5;
