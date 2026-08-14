-- Listing 19.2 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
CREATE TABLE ticket_event_2025_07 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2025-07-01 00:00:00+00') TO ('2025-08-01 00:00:00+00');
CREATE TABLE ticket_event_2025_08 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2025-08-01 00:00:00+00') TO ('2025-09-01 00:00:00+00');
CREATE TABLE ticket_event_2025_09 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');
CREATE TABLE ticket_event_2025_10 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');
CREATE TABLE ticket_event_2025_11 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');
CREATE TABLE ticket_event_2025_12 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');
CREATE TABLE ticket_event_2026_01 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');
CREATE TABLE ticket_event_2026_02 PARTITION OF ticket_event_p
    FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');
CREATE TABLE ticket_event_default PARTITION OF ticket_event_p DEFAULT;
