-- Listing 19.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch19/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 19
CREATE INDEX event_part_ticket_idx ON ticket_event (ticket_id);

SELECT indexrelname AS partition_index,
       pg_size_pretty(pg_relation_size(indexrelid)) AS on_disk
FROM pg_stat_user_indexes
WHERE indexrelname LIKE '%ticket_id_idx'
ORDER BY indexrelname
LIMIT 4;
