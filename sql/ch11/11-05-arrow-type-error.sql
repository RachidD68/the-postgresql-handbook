-- Listing 11.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
-- Intentionally fails with SQLSTATE 42883
SELECT ticket_id
FROM ticket_event
WHERE event_kind = 'assigned' AND payload->'agent_id' = 3;
