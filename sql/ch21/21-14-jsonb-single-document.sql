-- Listing 21.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch21/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 21
SELECT jsonb_pretty(
    jsonb_build_object(
        'reference', t.reference,
        'subject',   t.subject,
        'comments',  coalesce(
            jsonb_agg(
                jsonb_build_object('author', c.author_kind, 'body', c.body)
                ORDER BY c.created_at
            ) FILTER (WHERE c.id IS NOT NULL),
            '[]'::jsonb)
    )
) AS document
FROM ticket AS t
LEFT JOIN ticket_comment AS c ON c.ticket_id = t.id
WHERE t.reference = 'LUM-1013'
GROUP BY t.reference, t.subject;
