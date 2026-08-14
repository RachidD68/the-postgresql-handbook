-- Listing 3.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch03/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 3
UPDATE customer
SET plan = 'enterprise'
WHERE email = 'fiona@harboranalytics.example';

SELECT full_name, plan FROM customer WHERE company_name = 'Harbor Analytics';
