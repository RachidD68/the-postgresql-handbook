-- Listing 14.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
BEGIN;
SELECT satisfaction FROM ticket WHERE id = 5;

-- [B]
BEGIN;
SELECT satisfaction FROM ticket WHERE id = 5;

-- [A]
UPDATE ticket SET satisfaction = 2 + 1 WHERE id = 5;
COMMIT;

-- [B]
UPDATE ticket SET satisfaction = 2 + 1 WHERE id = 5;
COMMIT;

-- [A]
SELECT satisfaction AS after_two_increments FROM ticket WHERE id = 5;

-- [A]
UPDATE ticket SET satisfaction = 2 WHERE id = 5;
