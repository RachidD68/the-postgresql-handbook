-- Listing 13.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE MATERIALIZED VIEW mv_monthly_stats AS
SELECT date_trunc('month', created_at)::date AS month_of,
       count(*) AS filed,
       count(*) FILTER (WHERE priority IN ('urgent', 'high')) AS hot,
       count(resolved_at) AS resolved,
       round(avg(resolution_minutes), 0) AS avg_resolution
FROM ticket
GROUP BY month_of
ORDER BY month_of;

SELECT month_of, filed, hot, resolved, avg_resolution
FROM mv_monthly_stats;
