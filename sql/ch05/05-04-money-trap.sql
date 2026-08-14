-- Listing 5.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
-- The cent leaves at the moment of division, not at display time:
SELECT 100::money / 3     AS each_rounded,
       100.00::numeric / 3 AS each_honest;
