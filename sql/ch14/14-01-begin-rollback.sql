-- Listing 14.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
BEGIN;

UPDATE ticket SET status = 'resolved', resolved_at = '2026-01-15 09:20:00+00'
WHERE reference = 'LUM-1036';

INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
VALUES (36, 'refund_issued', '{"amount_cents": 12900}',
        '2026-01-15 09:20:00+00');

SELECT status, resolved_at IS NOT NULL AS has_resolution
FROM ticket WHERE reference = 'LUM-1036';

ROLLBACK;

SELECT status, resolved_at IS NOT NULL AS has_resolution
FROM ticket WHERE reference = 'LUM-1036';
