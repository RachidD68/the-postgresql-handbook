-- Listing 7.7 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
INSERT INTO customer (company_name, full_name, email, plan, signed_up_at)
VALUES ('Nimbus Analytics', 'Wei Zhang', 'wei@nimbusanalytics.example',
        'free', '2026-01-14 18:00:00+00')
RETURNING id, full_name;
