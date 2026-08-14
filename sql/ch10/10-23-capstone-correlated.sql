-- Listing 10.23 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
-- Way 1: correlated subqueries. Each column re-asks the ticket table.
SELECT a.full_name,
       (SELECT count(t.resolution_minutes) FROM ticket AS t
        WHERE t.assigned_agent_id = a.id)              AS resolved,
       (SELECT round(avg(t.resolution_minutes), 0) FROM ticket AS t
        WHERE t.assigned_agent_id = a.id)              AS avg_minutes,
       (SELECT count(*) + 1 FROM agent AS rival
        WHERE (SELECT count(r.resolution_minutes) FROM ticket AS r
               WHERE r.assigned_agent_id = rival.id) >
              (SELECT count(t.resolution_minutes) FROM ticket AS t
               WHERE t.assigned_agent_id = a.id))      AS rank_hand_rolled
FROM agent AS a
ORDER BY resolved DESC, a.full_name;
