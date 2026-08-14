-- Listing 6.20 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
ALTER TABLE ticket
    ADD CONSTRAINT ticket_subject_length_check
        CHECK (length(subject) <= 120) NOT VALID;

-- New writes are policed from this instant. History, whenever we're ready:
ALTER TABLE ticket VALIDATE CONSTRAINT ticket_subject_length_check;
