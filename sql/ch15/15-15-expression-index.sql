-- Listing 15.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX ticket_subject_lower_idx ON ticket (lower(subject));

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE lower(subject) = 'invoice question';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE subject = 'Invoice question';
