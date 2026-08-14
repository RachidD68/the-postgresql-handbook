-- Listing 4.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
SELECT count(*) AS still_with_us
FROM ticket
WHERE status IN ('open', 'waiting_on_customer');
