-- Listing 11.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT payload->>'channel' AS arrived_via, count(*) AS tickets
FROM ticket_event
WHERE event_kind = 'created'
GROUP BY arrived_via
ORDER BY tickets DESC, arrived_via;
