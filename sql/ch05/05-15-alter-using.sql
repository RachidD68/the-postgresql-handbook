-- Listing 5.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
ALTER TABLE ticket
    ALTER COLUMN priority TYPE ticket_priority
    USING priority::ticket_priority;
