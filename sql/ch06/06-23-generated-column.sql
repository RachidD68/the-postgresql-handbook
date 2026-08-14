-- Listing 6.23 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
ALTER TABLE ticket
    ADD COLUMN resolution_minutes integer
        GENERATED ALWAYS AS
            ((EXTRACT(EPOCH FROM (resolved_at - created_at)) / 60)::integer)
        STORED;
