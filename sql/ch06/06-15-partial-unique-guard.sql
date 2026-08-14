-- Listing 6.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
CREATE UNIQUE INDEX ticket_open_duplicate_guard
    ON ticket (customer_id, subject)
    WHERE status = 'open';
