-- Listing 9.20 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
WITH RECURSIVE thread AS (
    SELECT id, parent_comment_id, body, 1 AS depth
    FROM ticket_comment
    WHERE ticket_id = 36 AND parent_comment_id IS NULL
  UNION ALL
    SELECT tc.id, tc.parent_comment_id, tc.body, thread.depth + 1
    FROM ticket_comment AS tc
    JOIN thread ON tc.parent_comment_id = thread.id
)
SELECT depth, id, left(body, 48) AS says
FROM thread
ORDER BY depth;
