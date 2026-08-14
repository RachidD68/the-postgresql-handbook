-- Listing 17.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
SET ROLE lumina_app;
SET app.customer_id = '1';

SELECT count(*) AS my_tickets FROM ticket;

SELECT reference, status FROM ticket ORDER BY reference LIMIT 3;
