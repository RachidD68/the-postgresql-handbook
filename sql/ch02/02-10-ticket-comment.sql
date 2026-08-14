-- Listing 2.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.ticket_comment (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id          bigint NOT NULL,
    parent_comment_id  bigint,
    author_kind        text NOT NULL,
    author_id          bigint NOT NULL,
    body               text NOT NULL,
    created_at         timestamptz NOT NULL
);
