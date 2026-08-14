-- Listing 20.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch20/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 20
CREATE PUBLICATION open_board FOR TABLE ticket
    WHERE (status = 'open');

DROP PUBLICATION open_board;
