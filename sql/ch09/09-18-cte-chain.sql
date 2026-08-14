-- Listing 9.18 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
WITH team_speed AS (
    SELECT tm.name, round(avg(t.resolution_minutes), 0) AS avg_minutes
    FROM ticket AS t
    JOIN team AS tm ON tm.id = t.team_id
    GROUP BY tm.name
),
company_speed AS (
    SELECT round(avg(resolution_minutes), 0) AS avg_minutes
    FROM ticket
)
SELECT ts.name, ts.avg_minutes, cs.avg_minutes AS company_avg
FROM team_speed AS ts
CROSS JOIN company_speed AS cs
WHERE ts.avg_minutes > cs.avg_minutes;
