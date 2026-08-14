-- Listing 13.22 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
UPDATE ticket SET priority = 'high' WHERE reference = 'LUM-1002';

SELECT reference,
       updated_at IS NOT NULL          AS touched,
       updated_at > created_at         AS clock_sane
FROM ticket
WHERE reference IN ('LUM-1001', 'LUM-1002')
ORDER BY reference;
