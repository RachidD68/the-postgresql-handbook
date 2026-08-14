-- Listing 3.26 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
INSERT INTO tag (name, description)
VALUES ('vip', 'Flagged for white-glove handling')
RETURNING id, name;
