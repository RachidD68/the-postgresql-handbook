-- Listing 6.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
SELECT conname, contype
FROM pg_constraint
WHERE conrelid = 'ticket'::regclass
  AND contype IN ('p', 'u', 'f', 'c')
ORDER BY contype, conname;
