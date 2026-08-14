-- Listing 14.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
-- [A]
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS hot FROM ticket
WHERE status = 'open' AND priority IN ('urgent', 'high');

-- [B]
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS hot FROM ticket
WHERE status = 'open' AND priority IN ('urgent', 'high');

-- [A]
UPDATE ticket SET priority = 'normal' WHERE reference = 'LUM-1031';

-- [B]
UPDATE ticket SET priority = 'normal' WHERE reference = 'LUM-1034';

-- [A]
COMMIT;

-- [B] expect-error 40001
COMMIT;

-- [A]
UPDATE ticket SET priority = 'high' WHERE reference = 'LUM-1031';
