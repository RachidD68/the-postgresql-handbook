-- Listing 17.2 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
SELECT rolname, rolcanlogin
FROM pg_roles
WHERE rolname IN ('postgres', 'lumina_app', 'lumina_readonly', 'support_agent')
ORDER BY rolname;
