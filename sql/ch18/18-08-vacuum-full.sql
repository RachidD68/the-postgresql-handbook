-- Listing 18.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch18/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 18
VACUUM FULL vac_scratch;

SELECT pg_size_pretty(pg_relation_size('vac_scratch')) AS on_disk;

DROP TABLE vac_scratch;
