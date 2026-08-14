-- Listing 11.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT jsonb_pretty(jsonb_build_object(
    'reference', t.reference,
    'status',    t.status,
    'customer',  c.company_name,
    'tags',      (SELECT jsonb_agg(tg.name ORDER BY tg.name)
                  FROM ticket_tag AS tt
                  JOIN tag AS tg ON tg.id = tt.tag_id
                  WHERE tt.ticket_id = t.id)
)) AS document
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE t.reference = 'LUM-1036';
