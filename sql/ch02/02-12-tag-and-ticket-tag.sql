-- Listing 2.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.tag (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         text NOT NULL UNIQUE,
    description  text NOT NULL
);

CREATE TABLE lumina.ticket_tag (
    ticket_id  bigint NOT NULL,
    tag_id     bigint NOT NULL,
    PRIMARY KEY (ticket_id, tag_id)
);
