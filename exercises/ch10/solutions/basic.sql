-- Solution to Exercise 10.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 10

SELECT t.reference, tm.name AS team, t.resolution_minutes,
       round(avg(t.resolution_minutes)
             OVER (PARTITION BY t.team_id), 0) AS team_avg,
       t.resolution_minutes
           - round(avg(t.resolution_minutes)
                   OVER (PARTITION BY t.team_id), 0) AS delta
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
WHERE t.resolution_minutes IS NOT NULL
ORDER BY delta DESC;

-- 26 resolved tickets. The slowest overshoot is LUM-1023: 5,560 minutes
-- against Onboarding's 1,419 average — 4,141 minutes over. Repeating the
-- window expression is idiomatic; so is hoisting it into a CTE.
