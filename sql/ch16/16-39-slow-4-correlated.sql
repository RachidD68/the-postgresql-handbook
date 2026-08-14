-- Listing 16.39 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch16/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 16
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT t.reference,
       (SELECT count(*) FROM ticket_event WHERE ticket_event.ticket_id = t.id)
FROM ticket AS t
WHERE t.customer_id = 507;

EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF)
SELECT t.reference, count(e.id)
FROM ticket AS t
LEFT JOIN ticket_event AS e ON e.ticket_id = t.id
WHERE t.customer_id = 507
GROUP BY t.reference;
