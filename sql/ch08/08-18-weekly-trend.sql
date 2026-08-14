-- Listing 8.18 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT date_trunc('week', created_at)::date AS week_of,
       count(*) AS tickets_filed
FROM ticket
GROUP BY week_of
ORDER BY week_of;
