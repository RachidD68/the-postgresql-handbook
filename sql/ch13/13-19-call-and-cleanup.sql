-- Listing 13.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CALL archive_old_events('2025-12-01 00:00:00+00', 25);

SELECT (SELECT count(*) FROM event_scratch) AS still_hot,
       (SELECT count(*) FROM event_archive) AS archived;

DROP TABLE event_scratch;
DROP TABLE event_archive;
DROP PROCEDURE archive_old_events(timestamptz, int);
