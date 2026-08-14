-- Listing 13.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                    status, priority, channel, created_at)
VALUES ('LUM-1042', 3, 3, 'Matview staleness demo', 'Not in the stats yet.',
        'open', 'high', 'web', '2026-01-15 09:45:00+00');

SELECT count(*) AS live_january
FROM ticket
WHERE created_at >= '2026-01-01 00:00:00+00';

SELECT filed AS cached_january
FROM mv_monthly_stats
WHERE month_of = '2026-01-01';
