-- Listing 4.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT count(*) AS with_like  FROM ticket WHERE subject LIKE '%invoice%';

SELECT count(*) AS with_ilike FROM ticket WHERE subject ILIKE '%invoice%';
