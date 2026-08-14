-- Listing 7.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT count(*) AS with_on
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id;

SELECT count(*) AS with_where
FROM ticket AS t, customer AS c
WHERE c.id = t.customer_id;
