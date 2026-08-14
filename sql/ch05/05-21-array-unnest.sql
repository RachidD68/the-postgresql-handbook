-- Listing 5.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch05/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 5
SELECT unnest(ARRAY['billing', 'login', 'urgent-review']) AS tag_name;
