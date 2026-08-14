-- Listing 4.32 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT lower(full_name) AS handle,
       length(full_name) AS chars,
       left(full_name, 1) || '.' AS initial
FROM agent;
