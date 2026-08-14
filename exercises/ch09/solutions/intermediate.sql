-- Solution to Exercise 9.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 9

SELECT t.reference,
       latest.created_at::date AS last_word_on,
       left(latest.body, 40) AS says
FROM ticket AS t
LEFT JOIN LATERAL (
    SELECT body, created_at
    FROM ticket_comment
    WHERE ticket_id = t.id
    ORDER BY created_at DESC
    LIMIT 1
) AS latest ON true
ORDER BY t.reference;
-- 40 rows — every seed ticket has comments, so nothing vanished.

-- The future-proofing keyword is LEFT (JOIN LATERAL ... ON true). Under
-- CROSS JOIN LATERAL a newborn, commentless ticket produces zero lateral
-- rows and vanishes from the report; under LEFT it survives with NULLs.
