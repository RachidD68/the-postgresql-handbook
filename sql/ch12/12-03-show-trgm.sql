-- Listing 12.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT show_trgm('crash') AS crash_trigrams,
       show_trgm('crush') AS crush_trigrams,
       similarity('crash', 'crush') AS how_alike;
