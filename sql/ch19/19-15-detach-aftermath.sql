-- Listing 19.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
SELECT count(*) AS august_survives FROM ticket_event_2025_08;

SELECT min(occurred_at)::date AS oldest_still_inside FROM ticket_event;
