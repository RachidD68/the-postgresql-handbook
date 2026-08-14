-- Listing 15.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX ticket_workload_idx
    ON ticket (assigned_agent_id, status)
    INCLUDE (priority, created_at);

EXPLAIN (COSTS OFF)
SELECT priority, created_at
FROM ticket
WHERE assigned_agent_id = 105 AND status = 'open';
