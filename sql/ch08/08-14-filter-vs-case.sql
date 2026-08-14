-- Listing 8.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
-- The folk idiom: sum a 1 for every row you meant to count.
SELECT tm.name AS team,
       count(*) AS total,
       sum(CASE WHEN t.status = 'closed' THEN 1 ELSE 0 END) AS closed
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
GROUP BY tm.name
ORDER BY tm.name;

-- The modern form: each aggregate carries its own WHERE.
SELECT tm.name AS team,
       count(*) AS total,
       count(*) FILTER (WHERE t.status = 'closed')             AS closed,
       count(*) FILTER (WHERE t.status = 'open')               AS open,
       avg(t.satisfaction) FILTER (WHERE t.status = 'closed')  AS avg_score
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
GROUP BY tm.name
ORDER BY tm.name;
