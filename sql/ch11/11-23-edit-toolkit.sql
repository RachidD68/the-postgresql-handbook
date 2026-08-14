-- Listing 11.23 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT jsonb_set(custom_fields, '{device,app_version}', '"4.9.0"') AS bumped
FROM ticket
WHERE reference = 'LUM-1033';

SELECT custom_fields || '{"vip": true}'  AS merged,
       custom_fields  - 'po_number'        AS trimmed
FROM ticket
WHERE reference = 'LUM-1001';
