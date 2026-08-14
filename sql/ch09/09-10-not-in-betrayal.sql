-- Listing 9.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT full_name
FROM agent
WHERE id NOT IN (SELECT assigned_agent_id FROM ticket);
