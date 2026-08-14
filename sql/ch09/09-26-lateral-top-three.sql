-- Listing 9.26 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
SELECT t.reference, tc.created_at::date AS on_day, left(tc.body, 40) AS says
FROM ticket AS t
CROSS JOIN LATERAL (
    SELECT body, created_at
    FROM ticket_comment
    WHERE ticket_id = t.id
    ORDER BY created_at DESC
    LIMIT 3
) AS tc
WHERE t.status = 'open' AND t.priority IN ('urgent', 'high')
ORDER BY t.reference, tc.created_at DESC;
