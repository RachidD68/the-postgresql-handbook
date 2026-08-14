-- Listing 8.12 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT c.company_name, count(*) AS tickets_filed
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE c.plan = 'enterprise'
GROUP BY c.company_name
HAVING count(*) >= 4
ORDER BY tickets_filed DESC, c.company_name;
