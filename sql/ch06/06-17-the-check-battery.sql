-- Listing 6.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
ALTER TABLE ticket
    ADD CONSTRAINT ticket_status_check
        CHECK (status IN ('open', 'waiting_on_customer', 'resolved', 'closed')),
    ADD CONSTRAINT ticket_satisfaction_check
        CHECK (satisfaction BETWEEN 1 AND 5),
    ADD CONSTRAINT ticket_resolution_order_check
        CHECK (resolved_at >= created_at);

ALTER TABLE ticket_comment
    ADD CONSTRAINT comment_author_kind_check
        CHECK (author_kind IN ('agent', 'customer'));
