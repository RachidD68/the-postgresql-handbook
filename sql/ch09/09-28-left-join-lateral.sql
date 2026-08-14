-- Listing 9.28 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT a.full_name, latest.created_at::date AS last_wrote, left(latest.body, 32) AS says
FROM agent AS a
LEFT JOIN LATERAL (
    SELECT body, created_at
    FROM ticket_comment
    WHERE author_kind = 'agent' AND author_id = a.id
    ORDER BY created_at DESC
    LIMIT 1
) AS latest ON true
ORDER BY a.id;
