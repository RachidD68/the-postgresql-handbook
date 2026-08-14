-- Listing 14.28 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
BEGIN;
SET deadlock_timeout = '500ms';
UPDATE ticket SET priority = priority WHERE id = 1;

-- [B]
BEGIN;
SET deadlock_timeout = '10s';
UPDATE ticket SET priority = priority WHERE id = 2;

-- [A] blocks
UPDATE ticket SET priority = priority WHERE id = 2;

-- [B] blocks
UPDATE ticket SET priority = priority WHERE id = 1;

-- [A] resumes expect-error 40P01

-- [B] resumes

-- [A]
ROLLBACK;

-- [B]
ROLLBACK;
