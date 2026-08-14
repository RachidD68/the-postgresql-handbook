-- Listing 14.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
BEGIN;
UPDATE ticket SET priority = 'high' WHERE reference = 'LUM-1040';

-- [B]
SELECT priority FROM ticket WHERE reference = 'LUM-1040';

-- [A]
COMMIT;

-- [B]
SELECT priority FROM ticket WHERE reference = 'LUM-1040';

-- [A]
UPDATE ticket SET priority = 'low' WHERE reference = 'LUM-1040';
