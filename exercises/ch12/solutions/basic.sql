-- Solution to Exercise 12.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 12,
--              then sql/ch12/12-15-the-search-column.sql (the chapter's
--              search_tsv column and GIN index).

SELECT reference, left(subject, 40) AS subject,
       round(ts_rank(search_tsv,
                     websearch_to_tsquery('english', 'export'))::numeric,
             4) AS rank
FROM ticket
WHERE search_tsv @@ websearch_to_tsquery('english', 'export')
ORDER BY rank DESC, reference;

-- The top hits score identically because all of them carry the export
-- lexeme in their A-weighted subject — same zone, same weight, near-equal
-- rank. For a ticket to score differently it would have to mention exports
-- only in its B-weighted body, dropping it to the 0.2 range exactly as
-- invoice's bottom half did in listing 12.16.
