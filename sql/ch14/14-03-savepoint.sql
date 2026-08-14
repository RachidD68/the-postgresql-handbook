-- Listing 14.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
BEGIN;

INSERT INTO tag (name, description) VALUES ('q1-review', 'Quarterly sweep');

SAVEPOINT before_risky;
INSERT INTO tag (name, description) VALUES ('billing', 'duplicate!');

ROLLBACK TO SAVEPOINT before_risky;

SELECT count(*) AS new_tags FROM tag WHERE name = 'q1-review';

ROLLBACK;
