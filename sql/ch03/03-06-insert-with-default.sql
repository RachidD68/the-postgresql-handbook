-- Listing 3.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
INSERT INTO ticket_event (ticket_id, event_kind, occurred_at)
VALUES (1, 'demo_note', '2026-01-15 09:05:00+00');

SELECT event_kind, payload
FROM ticket_event
WHERE event_kind = 'demo_note';   -- WHERE picks the rows; Chapter 4 is all about it
