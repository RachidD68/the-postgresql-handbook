-- Listing 4.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT reference, subject
FROM ticket
WHERE assigned_agent_id = NULL;
