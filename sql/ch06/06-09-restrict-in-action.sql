-- Listing 6.9 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
-- Intentionally fails with SQLSTATE 23001
DELETE FROM customer WHERE full_name = 'Fiona O''Brien';
