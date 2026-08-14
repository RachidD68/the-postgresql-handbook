-- Listing 17.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
SET ROLE lumina_app;
SET app.customer_id = '2';

SELECT count(*) AS my_tickets FROM ticket;
