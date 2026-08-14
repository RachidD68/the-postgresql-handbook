-- Listing 6.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
-- Intentionally fails with SQLSTATE 23514
UPDATE ticket SET status = 'banana' WHERE reference = 'LUM-1003';
