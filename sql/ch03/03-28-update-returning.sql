-- Listing 3.28 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
UPDATE ticket
SET assigned_agent_id = 1,
    first_response_at = '2026-01-15 09:12:00+00'
WHERE reference = 'LUM-1036'
RETURNING reference, assigned_agent_id, first_response_at;
