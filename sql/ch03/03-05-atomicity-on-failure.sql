-- Listing 3.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
-- Intentionally fails with SQLSTATE 23502
INSERT INTO tag (name, description)
VALUES
    ('escalation', 'Requests routed to a team lead'),
    ('follow-up',  NULL),
    ('regression', 'Something that used to work and broke');
