-- Listing 6.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
-- Intentionally fails with SQLSTATE 23503
ALTER TABLE ticket_comment
    ADD CONSTRAINT comment_ticket_fk
        FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE;
