-- Listing 11.27 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
UPDATE ticket
SET custom_fields = jsonb_set(custom_fields, '{status}', '"resolvd"')
WHERE reference = 'LUM-1001';

SELECT reference,
       status                    AS real_status,
       custom_fields->>'status'  AS shadow_status
FROM ticket
WHERE reference = 'LUM-1001';
