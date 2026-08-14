-- Listing 6.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
SELECT id, ticket_id, body
FROM ticket_comment
WHERE ticket_id = 41;
