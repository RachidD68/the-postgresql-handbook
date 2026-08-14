-- Solution to Exercise 12.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 12,
--              then sql/ch12/12-15-the-search-column.sql.

-- The compiled tsquery is written exactly once — in the FROM, as a lateral
-- item every other clause reuses. Title-above-body comes free: search_tsv
-- weights subjects A and bodies B, and ts_rank respects the zones.
SELECT t.reference,
       round(ts_rank(t.search_tsv, q)::numeric, 4) AS rank,
       ts_headline('english', t.body, q,
                   'MaxWords=10, MinWords=5') AS snippet
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id,
     websearch_to_tsquery('english', 'export') AS q
WHERE t.search_tsv @@ q
  AND c.company_name = 'Meridian Logistics'
  AND t.status = 'open'
ORDER BY rank DESC, t.reference;

-- Input 'export': one open Meridian ticket matches — LUM-1031.

-- The phrase input: swap the user string only.
SELECT q AS compiled,
       t.reference,
       ts_headline('english', t.body, q,
                   'MaxWords=10, MinWords=5') AS snippet
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id,
     websearch_to_tsquery('english', '"stuck at 90"') AS q
WHERE t.search_tsv @@ q
  AND c.company_name = 'Meridian Logistics'
  AND t.status = 'open'
ORDER BY t.reference;

-- What changed: the phrase compiles to 'stuck <2> 90' — the stop word
-- "at" vanished, but its DISTANCE survived as a positional demand. Both
-- inputs find LUM-1031; only the phrase version would refuse a ticket
-- that said "90 percent stuck."
