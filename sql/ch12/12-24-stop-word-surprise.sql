-- Listing 12.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT count(*) AS matches
FROM ticket
WHERE search_tsv @@ websearch_to_tsquery('english', 'the');
