-- Listing 12.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
ALTER TABLE ticket
    ADD COLUMN search_tsv tsvector
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', subject), 'A') ||
            setweight(to_tsvector('english', body),    'B')
        ) STORED;

CREATE INDEX ticket_search_idx ON ticket USING gin (search_tsv);
