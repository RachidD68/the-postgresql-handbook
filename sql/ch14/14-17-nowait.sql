-- Listing 14.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
BEGIN;
SELECT id FROM ticket WHERE reference = 'LUM-1036' FOR UPDATE;

-- [B] expect-error 55P03
SELECT id FROM ticket WHERE reference = 'LUM-1036' FOR UPDATE NOWAIT;

-- [A]
ROLLBACK;
