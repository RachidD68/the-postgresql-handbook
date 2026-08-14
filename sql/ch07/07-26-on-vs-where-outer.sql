-- Listing 7.26 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
-- Filter in WHERE: the join happens, then unmatched-and-filtered rows drop.
SELECT count(*) AS customers_shown
FROM customer AS c
LEFT JOIN ticket AS t ON t.customer_id = c.id
WHERE t.status = 'open';

-- Filter in ON: the join itself only matches open tickets; everyone survives.
SELECT count(*) AS customers_shown
FROM customer AS c
LEFT JOIN ticket AS t
  ON t.customer_id = c.id AND t.status = 'open';
