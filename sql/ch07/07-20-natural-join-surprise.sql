-- Listing 7.20 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT count(*) AS natural_matches
FROM ticket NATURAL JOIN customer;
