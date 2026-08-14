-- Listing 10.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch10/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 10
SELECT a.full_name,
       count(t.resolution_minutes) AS resolved,
       row_number() OVER (ORDER BY count(t.resolution_minutes) DESC,
                          a.full_name)                            AS row_num,
       rank()       OVER (ORDER BY count(t.resolution_minutes) DESC) AS rnk,
       dense_rank() OVER (ORDER BY count(t.resolution_minutes) DESC) AS dense
FROM agent AS a
LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.full_name
ORDER BY row_num;
