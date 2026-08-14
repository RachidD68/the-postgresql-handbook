-- Listing 3.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
DELETE FROM ticket WHERE reference = 'LUM-1040';

-- The ticket is gone. Its conversation is not.
SELECT count(*) AS orphaned_comments
FROM ticket_comment
WHERE ticket_id = 40;
