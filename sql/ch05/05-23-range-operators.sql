-- Listing 5.23 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
SELECT tstzrange('2026-01-12 07:00+00', '2026-01-12 09:00+00') @> created_at
           AS arrived_during_window,
       tstzrange('2026-01-12 07:00+00', '2026-01-12 09:00+00') &&
       tstzrange('2026-01-12 08:30+00', '2026-01-12 10:00+00')
           AS windows_overlap
FROM ticket
WHERE reference = 'LUM-1036';
