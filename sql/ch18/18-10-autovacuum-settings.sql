-- Listing 18.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
SELECT name, setting
FROM pg_settings
WHERE name IN ('autovacuum',
               'autovacuum_vacuum_threshold',
               'autovacuum_vacuum_scale_factor',
               'autovacuum_naptime')
ORDER BY name;
