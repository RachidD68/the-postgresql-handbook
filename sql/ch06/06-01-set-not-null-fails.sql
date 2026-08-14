-- Listing 6.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
-- Intentionally fails with SQLSTATE 23502
ALTER TABLE ticket
    ALTER COLUMN satisfaction SET NOT NULL;
