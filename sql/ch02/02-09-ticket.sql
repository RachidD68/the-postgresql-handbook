-- Listing 2.9 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.ticket (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference          text NOT NULL UNIQUE,
    customer_id        bigint NOT NULL,
    assigned_agent_id  bigint,
    team_id            bigint NOT NULL,
    subject            text NOT NULL,
    body               text NOT NULL,
    status             text NOT NULL,
    priority           text NOT NULL,
    channel            text NOT NULL,
    created_at         timestamptz NOT NULL,
    first_response_at  timestamptz,
    resolved_at        timestamptz,
    closed_at          timestamptz,
    satisfaction       smallint
);
