-- Listing 10.27 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
WITH monthly AS (
    SELECT date_trunc('month', created_at)::date AS month_of,
           count(*) AS filed,
           count(*) FILTER (WHERE priority IN ('urgent', 'high')) AS hot
    FROM ticket
    GROUP BY month_of
)
SELECT month_of, filed,
       filed - lag(filed) OVER (ORDER BY month_of) AS filed_delta,
       hot,
       hot - lag(hot) OVER (ORDER BY month_of)     AS hot_delta
FROM monthly
ORDER BY month_of;
