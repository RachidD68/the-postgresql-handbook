-- Solution to Exercise 10.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 10

SELECT a.full_name,
       count(t.resolution_minutes) AS resolved,
       first_value(count(t.resolution_minutes))
           OVER (ORDER BY count(t.resolution_minutes) DESC) AS leader,
       first_value(count(t.resolution_minutes))
           OVER (ORDER BY count(t.resolution_minutes) DESC)
           - count(t.resolution_minutes) AS behind
FROM agent AS a
LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.full_name
ORDER BY resolved DESC, a.full_name;

-- Amara Diallo leads with 6; Dmitri Volkov trails by 3.
--
-- Why first_value needs no frame widening: the default frame (RANGE
-- UNBOUNDED PRECEDING to CURRENT ROW) always reaches back to the
-- partition's start — where the leader lives. last_value needed the frame
-- widened in listing 10.11 because the default frame's FAR end stops at the
-- current row; the ambush only guards that end.
