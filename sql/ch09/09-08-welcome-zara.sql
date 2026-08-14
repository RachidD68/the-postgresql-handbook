-- Listing 9.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
INSERT INTO agent (team_id, manager_id, full_name, email, hired_on)
VALUES (3, 5, 'Zara Ahmed', 'zara.ahmed@lumina.example', '2026-01-15')
RETURNING id, full_name;
