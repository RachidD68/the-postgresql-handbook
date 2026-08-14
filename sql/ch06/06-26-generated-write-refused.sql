-- Listing 6.26 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
-- Intentionally fails with SQLSTATE 428C9
UPDATE ticket SET resolution_minutes = 1 WHERE reference = 'LUM-1005';
