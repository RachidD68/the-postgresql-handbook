-- Listing 6.2 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                    status, priority, channel, created_at)
VALUES ('LUM-1041', 3, 3, 'Doomed demo ticket', 'Exists to be deleted.',
        'open', 'low', 'web', '2026-01-15 09:20:00+00');

INSERT INTO ticket_comment (ticket_id, author_kind, author_id, body, created_at)
VALUES (41, 'customer', 3, 'I will outlive my ticket.', '2026-01-15 09:21:00+00');

DELETE FROM ticket WHERE reference = 'LUM-1041';
