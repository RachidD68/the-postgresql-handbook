-- Listing 5.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
SELECT gen_random_uuid() AS v4,
       uuidv7()          AS v7;
