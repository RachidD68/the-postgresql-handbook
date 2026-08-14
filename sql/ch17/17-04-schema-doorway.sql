-- Listing 17.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
REVOKE ALL ON SCHEMA lumina FROM PUBLIC;
GRANT USAGE ON SCHEMA lumina TO lumina_app, lumina_readonly, support_agent;
