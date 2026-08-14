-- Listing 3.32 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
CREATE TABLE scratch_note (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    body  text NOT NULL
);

INSERT INTO scratch_note (body)
VALUES ('first'), ('second'), ('third');

-- Empty it wholesale, and reset the id counter while we're at it:
TRUNCATE scratch_note RESTART IDENTITY;

INSERT INTO scratch_note (body) VALUES ('fresh start')
RETURNING id;
