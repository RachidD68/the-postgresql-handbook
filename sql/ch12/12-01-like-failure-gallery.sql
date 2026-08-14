-- Listing 12.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT count(*) AS says_crash
FROM ticket
WHERE body LIKE '%crashing%';

SELECT reference, subject
FROM ticket
WHERE subject ILIKE '%crash%' OR body ILIKE '%crash%';
