-- Listing 11.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT reference,
       custom_fields#>'{device}'             AS the_object,
       custom_fields#>>'{device,os}'         AS os,
       custom_fields#>>'{device,app_version}' AS app
FROM ticket
WHERE custom_fields ? 'device'
ORDER BY reference;
