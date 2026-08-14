-- Listing 15.9 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX ticket_team_status_idx ON ticket (team_id, status);

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE team_id = 3 AND status = 'open';

EXPLAIN (COSTS OFF)
SELECT reference FROM ticket WHERE status = 'open';
