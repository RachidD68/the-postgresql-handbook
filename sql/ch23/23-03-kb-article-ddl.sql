-- Listing 23.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
CREATE TABLE IF NOT EXISTS kb_article (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id        bigint,
    title            text NOT NULL,
    body             text NOT NULL,
    embedding        vector(768) NOT NULL,
    embedding_model  text NOT NULL,
    metadata         jsonb NOT NULL DEFAULT '{}',
    search_tsv       tsvector
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', title), 'A') ||
            setweight(to_tsvector('english', body),  'B')
        ) STORED,
    created_at       timestamptz NOT NULL
);
