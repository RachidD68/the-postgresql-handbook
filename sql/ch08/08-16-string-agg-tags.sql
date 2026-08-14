-- Listing 8.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT t.reference,
       string_agg(tg.name, ', ' ORDER BY tg.name) AS tags
FROM ticket AS t
JOIN ticket_tag AS tt ON tt.ticket_id = t.id
JOIN tag AS tg ON tg.id = tt.tag_id
WHERE t.status = 'open'
GROUP BY t.reference
ORDER BY t.reference;
