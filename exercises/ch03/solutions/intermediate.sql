-- Solution to Exercise 3.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 3

-- LUM-1039 is ticket 39 (customer 10, unassigned). Its thread ends at
-- comment 117, and the seed's comment ids stop at 120 — so the three new
-- rows will be 121, 122, 123, which lets one multi-row INSERT reference
-- ids it is about to create. Safe only as this database's lone writer;
-- in application code, RETURNING replaces the guess.
INSERT INTO ticket_comment
    (ticket_id, parent_comment_id, author_kind, author_id, body, created_at)
VALUES
    (39, 117, 'customer', 10,
     'Following up - the tax deadline is Friday. Any progress?',
     '2026-01-15 09:00:00+00'),
    (39, 121, 'agent', 3,
     'Apologies for the wait. The invoice service is being redeployed; '
     || 'your November PDF regenerates within the hour.',
     '2026-01-15 09:20:00+00'),
    (39, 122, 'customer', 10,
     'Confirmed - the download works now. Thank you.',
     '2026-01-15 09:55:00+00')
RETURNING id, parent_comment_id, author_kind;

-- Verify each parent points where intended:
SELECT id, parent_comment_id, author_kind, left(body, 34) AS says
FROM ticket_comment
WHERE ticket_id = 39
ORDER BY id;
