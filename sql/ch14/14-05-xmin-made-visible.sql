-- Listing 14.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
BEGIN;

SELECT xmin::text = pg_current_xact_id()::text AS is_my_version
FROM ticket WHERE reference = 'LUM-1002';

UPDATE ticket SET priority = 'normal' WHERE reference = 'LUM-1002';

SELECT xmin::text = pg_current_xact_id()::text AS is_my_version
FROM ticket WHERE reference = 'LUM-1002';

ROLLBACK;
