-- Listing 7.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
SELECT report.full_name AS agent, boss.full_name AS reports_to
FROM agent AS report
LEFT JOIN agent AS boss ON boss.id = report.manager_id
ORDER BY report.id;
