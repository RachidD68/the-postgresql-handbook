-- Listing 12.22 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT t.reference, c.company_name,
       round(ts_rank(t.search_tsv, q)::numeric, 4) AS rank,
       ts_headline('english', t.subject, q) AS matched_title
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id,
     websearch_to_tsquery('english', 'export or crash') AS q
WHERE t.search_tsv @@ q
ORDER BY rank DESC, t.reference;
