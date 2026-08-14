-- Listing 10.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
WITH weekly AS (
    SELECT date_trunc('week', created_at)::date AS week_of,
           count(*) AS tickets
    FROM ticket
    GROUP BY week_of
)
SELECT week_of, tickets,
       sum(tickets) OVER (ORDER BY week_of
                          ROWS BETWEEN UNBOUNDED PRECEDING
                                   AND CURRENT ROW) AS running_total,
       round(avg(tickets) OVER (ORDER BY week_of
                                ROWS BETWEEN 2 PRECEDING
                                         AND CURRENT ROW), 1) AS moving_avg_3wk
FROM weekly
ORDER BY week_of;
