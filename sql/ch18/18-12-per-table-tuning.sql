-- Listing 18.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
ALTER TABLE ticket_event SET (
    autovacuum_vacuum_scale_factor = 0.02,
    autovacuum_vacuum_threshold = 1000
);
