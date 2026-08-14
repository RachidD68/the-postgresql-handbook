-- Listing 16.27 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT count(*) FROM ticket WHERE team_id = 1 AND assigned_agent_id = 104;

CREATE STATISTICS ticket_team_agent_stats (dependencies)
    ON team_id, assigned_agent_id FROM ticket;
ANALYZE ticket;

EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT count(*) FROM ticket WHERE team_id = 1 AND assigned_agent_id = 104;

DROP STATISTICS ticket_team_agent_stats;
ANALYZE ticket;
