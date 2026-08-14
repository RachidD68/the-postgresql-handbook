-- Listing 20.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch20/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 20
CREATE PUBLICATION lumina_pub FOR TABLE ticket;

DROP PUBLICATION lumina_pub;  -- the full demo lives in tools/ch20-replica-demo.sql
