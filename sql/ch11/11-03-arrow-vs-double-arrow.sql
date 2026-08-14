-- Listing 11.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT payload,
       payload->'channel'  AS arrow_one,
       payload->>'channel' AS arrow_two,
       pg_typeof(payload->'channel')  AS one_is,
       pg_typeof(payload->>'channel') AS two_is
FROM ticket_event
WHERE ticket_id = 1 AND event_kind = 'created';
