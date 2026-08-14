-- Listing 19.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
BEGIN;

LOCK TABLE ticket_event IN EXCLUSIVE MODE;

INSERT INTO ticket_event_p (id, ticket_id, event_kind, payload, occurred_at)
    OVERRIDING SYSTEM VALUE
SELECT id, ticket_id, event_kind, payload, occurred_at
FROM ticket_event;

SELECT setval(pg_get_serial_sequence('ticket_event_p', 'id'),
              (SELECT max(id) FROM ticket_event_p));

ALTER TABLE ticket_event   RENAME TO ticket_event_flat;
ALTER TABLE ticket_event_p RENAME TO ticket_event;

COMMIT;
