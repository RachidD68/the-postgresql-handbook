-- Listing 8.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT count(*)                     AS all_rows,
       count(satisfaction)          AS scored_rows,
       count(DISTINCT customer_id)  AS distinct_customers
FROM ticket;
