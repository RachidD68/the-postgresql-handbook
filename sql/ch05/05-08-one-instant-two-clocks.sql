-- Listing 5.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
SET timezone TO 'Asia/Tokyo';
SELECT created_at FROM ticket WHERE reference = 'LUM-1036';

SET timezone TO 'America/New_York';
SELECT created_at FROM ticket WHERE reference = 'LUM-1036';
