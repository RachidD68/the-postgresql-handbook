-- Listing 13.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE VIEW v_urgent_ticket AS
SELECT id, reference, subject, priority FROM ticket
WHERE priority = 'urgent';

SELECT count(*) AS urgent_before FROM v_urgent_ticket;

UPDATE v_urgent_ticket SET priority = 'high'
WHERE reference = 'LUM-1026';

SELECT count(*) AS urgent_after FROM v_urgent_ticket;
