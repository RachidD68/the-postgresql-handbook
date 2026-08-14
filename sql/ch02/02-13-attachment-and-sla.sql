-- Listing 2.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.attachment (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     bigint NOT NULL,
    comment_id    bigint,
    filename      text NOT NULL,
    content_kind  text NOT NULL,
    byte_size     bigint NOT NULL,
    uploaded_at   timestamptz NOT NULL
);

CREATE TABLE lumina.sla_policy (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                    text NOT NULL,
    applies_to_priority     text NOT NULL UNIQUE,
    first_response_minutes  integer NOT NULL,
    resolution_minutes      integer NOT NULL
);
