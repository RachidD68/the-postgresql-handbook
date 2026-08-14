-- Listing 10.9 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT tm.name AS team, a.full_name, a.hired_on,
       first_value(a.full_name)
           OVER (PARTITION BY tm.name ORDER BY a.hired_on) AS founding_hire,
       last_value(a.full_name)
           OVER (PARTITION BY tm.name ORDER BY a.hired_on) AS newest_hire
FROM agent AS a
JOIN team AS tm ON tm.id = a.team_id
ORDER BY tm.name, a.hired_on;
