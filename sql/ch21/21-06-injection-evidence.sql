-- Listing 21.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch21/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 21
-- The benign input: one exact-match row, as intended.
SELECT count(*) AS rows_returned
FROM ticket
WHERE reference = 'LUM-1001';

-- The SAME query with the attacker's input concatenated in, verbatim:
--   userInput = ' OR 1=1 --
SELECT count(*) AS rows_returned
FROM ticket
WHERE reference = '' OR 1=1 --';
