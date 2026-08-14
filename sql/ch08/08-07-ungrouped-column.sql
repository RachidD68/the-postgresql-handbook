-- Listing 8.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
-- Intentionally fails with SQLSTATE 42803
SELECT status, reference
FROM ticket
GROUP BY status;
