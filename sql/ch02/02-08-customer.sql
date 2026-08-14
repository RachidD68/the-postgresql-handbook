-- Listing 2.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
CREATE TABLE lumina.customer (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name  text NOT NULL,
    full_name     text NOT NULL,
    email         citext NOT NULL UNIQUE,
    plan          text NOT NULL,
    signed_up_at  timestamptz NOT NULL
);
