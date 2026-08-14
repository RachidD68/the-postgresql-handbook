-- Listing 4.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT team_id, full_name, hired_on
FROM agent
ORDER BY team_id, hired_on;
