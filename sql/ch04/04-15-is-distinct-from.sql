-- Listing 4.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT count(*) AS with_not_equal
FROM ticket
WHERE satisfaction <> 1;

SELECT count(*) AS with_is_distinct
FROM ticket
WHERE satisfaction IS DISTINCT FROM 1;
