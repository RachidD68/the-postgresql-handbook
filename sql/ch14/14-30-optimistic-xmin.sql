-- Listing 14.30 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch14/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 14
UPDATE ticket
SET subject = 'API returns 429 for batch export (editing)'
WHERE id = 1
  AND xmin = (SELECT xmin FROM ticket WHERE id = 1);

UPDATE ticket
SET subject = 'someone else edited first'
WHERE id = 1
  AND xmin = '1'::xid;
