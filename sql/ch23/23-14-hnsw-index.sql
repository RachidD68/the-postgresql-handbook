-- Listing 23.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
CREATE INDEX IF NOT EXISTS kb_article_embedding_hnsw
    ON kb_article USING hnsw (embedding vector_cosine_ops);
