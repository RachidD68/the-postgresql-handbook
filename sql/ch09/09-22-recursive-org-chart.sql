-- Listing 9.22 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
WITH RECURSIVE org AS (
    SELECT id, full_name, manager_id, 1 AS level
    FROM agent
    WHERE manager_id IS NULL
  UNION ALL
    SELECT a.id, a.full_name, a.manager_id, org.level + 1
    FROM agent AS a
    JOIN org ON a.manager_id = org.id
)
SELECT repeat('    ', level - 1) || full_name AS chart
FROM org
ORDER BY level, id;
