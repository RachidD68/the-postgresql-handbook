-- Listing 3.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
SELECT full_name || ' <' || email || '>' AS mailbox
FROM agent;
