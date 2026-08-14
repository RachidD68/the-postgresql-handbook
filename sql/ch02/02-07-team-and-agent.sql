-- Listing 2.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.team (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL,
    focus_area  text NOT NULL,
    created_at  timestamptz NOT NULL
);

CREATE TABLE lumina.agent (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id     bigint NOT NULL,
    manager_id  bigint,
    full_name   text NOT NULL,
    email       citext NOT NULL UNIQUE,
    hired_on    date NOT NULL
);
