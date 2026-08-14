-- Listing 10.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
WITH quartiled AS (
    SELECT reference, resolution_minutes,
           ntile(4) OVER (ORDER BY resolution_minutes) AS quartile
    FROM ticket
    WHERE resolution_minutes IS NOT NULL
)
SELECT quartile,
       count(*)               AS tickets,
       min(resolution_minutes) AS from_minutes,
       max(resolution_minutes) AS to_minutes
FROM quartiled
GROUP BY quartile
ORDER BY quartile;
