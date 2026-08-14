-- Listing 13.25 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
UPDATE ticket SET status = 'resolved', resolved_at = '2026-01-15 10:00:00+00'
WHERE reference = 'LUM-1036';

SELECT event_kind, payload
FROM ticket_event
WHERE ticket_id = 36
ORDER BY id DESC
LIMIT 1;
