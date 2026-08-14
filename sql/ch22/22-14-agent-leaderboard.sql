-- Listing 22.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch22/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 22
SELECT a.full_name,
       count(*) AS resolved_tickets,
       rank() OVER (ORDER BY count(*) DESC) AS leaderboard_rank
FROM ticket AS t
JOIN agent AS a ON a.id = t.assigned_agent_id
WHERE t.resolved_at IS NOT NULL
GROUP BY a.full_name
ORDER BY leaderboard_rank, a.full_name
LIMIT 5;
