-- Listing 11.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT t.reference, t.subject
FROM ticket AS t
JOIN ticket_event AS e ON e.ticket_id = t.id
WHERE e.event_kind = 'created'
  AND e.payload @> '{"channel": "phone", "priority": "urgent"}'
ORDER BY t.reference;
