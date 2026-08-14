-- Listing 3.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
SELECT reference, status, assigned_agent_id, first_response_at
FROM ticket
WHERE reference = 'LUM-1036';
