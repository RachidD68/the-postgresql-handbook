-- Listing 6.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
-- Intentionally fails with SQLSTATE 23505
-- Meridian Logistics' export ticket (LUM-1031) is still open...
INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                    status, priority, channel, created_at)
VALUES ('LUM-9999', 4, 2, 'Data export stuck at 90 percent', 'Filing it again!',
        'open', 'high', 'web', '2026-01-15 09:40:00+00');
