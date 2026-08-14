-- Listing 6.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
DELETE FROM agent WHERE full_name = 'Leo Tanaka';

SELECT count(*) AS back_in_the_queue
FROM ticket
WHERE assigned_agent_id IS NULL;
