-- Listing 12.18 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT reference, left(subject, 40) AS subject,
       round(ts_rank(search_tsv,
                     websearch_to_tsquery('english', 'invoice number'))::numeric,
             4) AS rank,
       round(ts_rank_cd(search_tsv,
                        websearch_to_tsquery('english', 'invoice number'))::numeric,
             4) AS rank_cd
FROM ticket
WHERE search_tsv @@ websearch_to_tsquery('english', 'invoice number')
ORDER BY rank_cd DESC, reference;
