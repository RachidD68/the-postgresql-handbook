-- Listing 17.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
-- Intentionally fails with SQLSTATE 42501
SET ROLE lumina_app;
DELETE FROM ticket WHERE reference = 'LUM-1001';
