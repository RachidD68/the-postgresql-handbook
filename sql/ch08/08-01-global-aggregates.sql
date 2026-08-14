-- Listing 8.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT count(*)            AS tickets,
       min(created_at)     AS oldest,
       max(created_at)     AS newest,
       avg(satisfaction)   AS avg_satisfaction
FROM ticket;
