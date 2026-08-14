-- Solution to Exercise 8.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 8

-- 100.0, not 100 — two bigint counts divide like integers otherwise.
SELECT CASE WHEN GROUPING(tm.name) = 1 THEN 'ALL TEAMS'
            ELSE tm.name
       END AS team,
       count(t.id) AS total,
       count(t.id) FILTER (WHERE t.status IN ('resolved', 'closed'))
           AS resolved_or_closed,
       round(100.0 * count(t.id) FILTER (WHERE t.status IN ('resolved', 'closed'))
             / count(t.id), 1) AS resolution_pct
FROM ticket AS t
JOIN team AS tm ON tm.id = t.team_id
GROUP BY ROLLUP (tm.name)
ORDER BY GROUPING(tm.name), tm.name;

--  team              | total | resolved_or_closed | resolution_pct
--  Billing           |    12 |                  7 |           58.3
--  Onboarding        |     7 |                  6 |           85.7
--  Technical Support |    21 |                 13 |           61.9
--  ALL TEAMS         |    40 |                 26 |           65.0
