-- Listing 19.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
CREATE TABLE ticket_event_p (
    id           bigint GENERATED ALWAYS AS IDENTITY,
    ticket_id    bigint NOT NULL,
    event_kind   text NOT NULL,
    payload      jsonb NOT NULL DEFAULT '{}',
    occurred_at  timestamptz NOT NULL,
    PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

ALTER TABLE ticket_event_p ADD CONSTRAINT event_ticket_fk
    FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE;
