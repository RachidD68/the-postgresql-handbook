-- Listing 9.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT week_start::date AS week_of
FROM generate_series('2025-12-22 00:00:00+00'::timestamptz,
                     '2026-01-12 00:00:00+00'::timestamptz,
                     interval '1 week') AS week_start;
