-- Listing 11.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT reference, custom_fields#>>'{device,os_version}' AS version
FROM ticket
WHERE custom_fields @? '$.device ? (@.os == "iOS")'
ORDER BY reference;
