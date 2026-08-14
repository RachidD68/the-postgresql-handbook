-- Listing 22.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch22/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 22
CREATE TABLE saved_reply (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id     bigint NOT NULL REFERENCES team (id) ON DELETE RESTRICT,
    title       text NOT NULL CHECK (length(title) <= 80),
    body        text NOT NULL,
    created_at  timestamptz NOT NULL
);
