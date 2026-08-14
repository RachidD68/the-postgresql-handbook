-- Listing 17.16 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
-- Intentionally fails with SQLSTATE 42501
SET ROLE lumina_app;
SET app.customer_id = '1';

INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                    status, priority, channel, created_at)
VALUES ('LUM-99999', 2, 1, 'Cross-tenant attempt', 'Should never land.',
        'open', 'low', 'web', '2026-01-15 09:50:00+00');
