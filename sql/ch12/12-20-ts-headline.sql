-- Listing 12.20 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT reference,
       ts_headline('english', body,
                   websearch_to_tsquery('english', 'invoice'),
                   'MaxWords = 12, MinWords = 6') AS why_it_matched
FROM ticket
WHERE search_tsv @@ websearch_to_tsquery('english', 'invoice')
ORDER BY ts_rank(search_tsv, websearch_to_tsquery('english', 'invoice')) DESC,
         reference
LIMIT 3;
