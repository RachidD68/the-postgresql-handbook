-- Listing 12.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT full_name, company_name,
       round(similarity(full_name, 'Fionna OBrien')::numeric, 2) AS score
FROM customer
WHERE full_name % 'Fionna OBrien'
ORDER BY score DESC;
