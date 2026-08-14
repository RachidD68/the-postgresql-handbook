-- Listing 11.25 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT t.reference, fields.key, fields.value
FROM ticket AS t,
     jsonb_each(t.custom_fields) AS fields
WHERE t.reference IN ('LUM-1004', 'LUM-1033')
ORDER BY t.reference, fields.key;
