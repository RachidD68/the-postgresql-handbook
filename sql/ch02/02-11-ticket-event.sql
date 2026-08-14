-- Listing 2.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.ticket_event (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id    bigint NOT NULL,
    event_kind   text NOT NULL,
    payload      jsonb NOT NULL DEFAULT '{}',
    occurred_at  timestamptz NOT NULL
);
