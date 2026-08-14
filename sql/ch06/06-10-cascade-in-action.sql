-- Listing 6.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                    status, priority, channel, created_at)
VALUES ('LUM-1042', 3, 3, 'Cascade demo', 'Watch my comment vanish with me.',
        'open', 'low', 'web', '2026-01-15 09:30:00+00');

INSERT INTO ticket_comment (ticket_id, author_kind, author_id, body, created_at)
VALUES (42, 'customer', 3, 'Tied to my ticket now.', '2026-01-15 09:31:00+00');

DELETE FROM ticket WHERE reference = 'LUM-1042';

SELECT count(*) AS surviving_comments FROM ticket_comment WHERE ticket_id = 42;
