-- Listing 6.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
DELETE FROM ticket_comment WHERE ticket_id = 41;

ALTER TABLE ticket_comment
    ADD CONSTRAINT comment_ticket_fk
        FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE,
    ADD CONSTRAINT comment_parent_fk
        FOREIGN KEY (parent_comment_id) REFERENCES ticket_comment (id)
        ON DELETE CASCADE;
