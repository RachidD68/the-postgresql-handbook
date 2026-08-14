-- Solution to Exercise 9.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 9

WITH RECURSIVE thread AS (
    -- Anchor: ALL parentless comments at once, no ticket filter.
    SELECT id, ticket_id, 1 AS depth
    FROM ticket_comment
    WHERE parent_comment_id IS NULL
    UNION ALL
    -- Step: each reply is one deeper than its parent; ticket_id rides along.
    SELECT c.id, c.ticket_id, thread.depth + 1
    FROM ticket_comment AS c
    JOIN thread ON thread.id = c.parent_comment_id
)
SELECT t.reference, max(thread.depth) AS max_depth
FROM thread
JOIN ticket AS t ON t.id = thread.ticket_id
GROUP BY t.reference
ORDER BY max_depth DESC, t.reference;

-- All 40 commented tickets tie at depth 3 — the wall of threes is the
-- success condition, exactly as the seed insists.
--
-- Why carry ticket_id: the recursion itself never reads it — replies find
-- parents by comment id alone. It is carried so the final GROUP BY can know
-- which tree each row fell from; drop it and the result is one anonymous
-- pile of depths.
