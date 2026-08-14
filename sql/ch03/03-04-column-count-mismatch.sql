-- Listing 3.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
-- Intentionally fails with SQLSTATE 42601
-- One column promised, two values supplied. PostgreSQL declines.
INSERT INTO tag (name)
VALUES ('orphaned-value', 'this description has no column to land in');
