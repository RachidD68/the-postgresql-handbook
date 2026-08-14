-- Listing 3.30 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
DELETE FROM ticket_tag
WHERE ticket_id = 40
RETURNING *;
