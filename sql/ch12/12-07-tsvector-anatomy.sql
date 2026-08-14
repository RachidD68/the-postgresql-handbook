-- Listing 12.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT to_tsvector('english',
           'The app keeps crashing when exporting reports') AS distilled;
