-- Listing 10.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
WITH monthly AS (
    SELECT date_trunc('month', created_at)::date AS month_of,
           count(*) AS tickets
    FROM ticket
    GROUP BY month_of
)
SELECT month_of, tickets,
       lag(tickets) OVER (ORDER BY month_of)           AS prior_month,
       tickets - lag(tickets) OVER (ORDER BY month_of) AS delta
FROM monthly
ORDER BY month_of;
