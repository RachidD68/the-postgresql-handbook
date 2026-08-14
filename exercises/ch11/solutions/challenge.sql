-- Solution to Exercise 11.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 11

SELECT jsonb_pretty(jsonb_build_object(
    'reference',    t.reference,
    'subject',      t.subject,
    'customer',     c.full_name,
    'tags',         (SELECT jsonb_agg(tg.name ORDER BY tg.name)
                     FROM ticket_tag AS tt
                     JOIN tag AS tg ON tg.id = tt.tag_id
                     WHERE tt.ticket_id = t.id),
    'last_comment', jsonb_build_object(
                        'on',   latest.created_at::date,
                        'says', left(latest.body, 40))
)) AS document
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
LEFT JOIN LATERAL (
    SELECT body, created_at
    FROM ticket_comment
    WHERE ticket_id = t.id
    ORDER BY created_at DESC
    LIMIT 1
) AS latest ON true
WHERE t.status = 'open'
  AND t.priority IN ('urgent', 'high')
ORDER BY t.reference;

-- Four documents: LUM-1031, LUM-1034, LUM-1036, LUM-1039.
--
-- What the LATERAL buys over a subquery-per-field: reuse. last_comment
-- needs two fields from the SAME newest comment; as two scalar subqueries
-- the ORDER BY ... LIMIT 1 runs twice and must agree twice. The LATERAL
-- fetches the row once and lets jsonb_build_object pick it apart.
