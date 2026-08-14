-- Listing 5.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
-- Intentionally fails with SQLSTATE 22003
SELECT 2147483647::integer + 1 AS one_too_many;
