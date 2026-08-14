-- Listing 10.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT tm.name AS team, a.full_name,
       last_value(a.full_name)
           OVER (PARTITION BY tm.name ORDER BY a.hired_on
                 ROWS BETWEEN UNBOUNDED PRECEDING
                          AND UNBOUNDED FOLLOWING) AS newest_hire
FROM agent AS a
JOIN team AS tm ON tm.id = a.team_id
ORDER BY tm.name, a.hired_on;
