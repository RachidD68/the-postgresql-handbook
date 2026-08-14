-- Listing 12.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT reference, left(subject, 40) AS subject,
       round(ts_rank(search_tsv,
                     websearch_to_tsquery('english', 'invoice'))::numeric,
             4) AS rank
FROM ticket
WHERE search_tsv @@ websearch_to_tsquery('english', 'invoice')
ORDER BY rank DESC, reference;
