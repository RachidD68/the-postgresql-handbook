-- Listing 19.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
CREATE TABLE ticket_event_2026_03 PARTITION OF ticket_event
    FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');

\timing on
DELETE FROM ticket_event
WHERE occurred_at >= '2025-07-01 00:00:00+00'
  AND occurred_at <  '2025-08-01 00:00:00+00';

ALTER TABLE ticket_event DETACH PARTITION ticket_event_2025_08;
\timing off
