-- Listing 13.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
SELECT reference,
       fn_ticket_age(id, '2026-01-15 09:00:00+00') AS age,
       fn_resolution_summary(id) AS summary
FROM ticket
WHERE reference IN ('LUM-1001', 'LUM-1031', 'LUM-1036')
ORDER BY reference;
