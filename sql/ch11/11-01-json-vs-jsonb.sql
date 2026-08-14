-- Listing 11.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT '{"b": 1, "a": 1, "a": 2}'::json  AS stored_as_text,
       '{"b": 1, "a": 1, "a": 2}'::jsonb AS stored_as_tree;
