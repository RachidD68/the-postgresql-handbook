-- Listing 9.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT c.company_name, counts.tickets_filed
FROM (SELECT customer_id, count(*) AS tickets_filed
      FROM ticket
      GROUP BY customer_id) AS counts
JOIN customer AS c ON c.id = counts.customer_id
WHERE counts.tickets_filed >= 4
ORDER BY counts.tickets_filed DESC, c.company_name;
