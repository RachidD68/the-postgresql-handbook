-- Listing 15.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX ticket_custom_fields_gin ON ticket USING gin (custom_fields);

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket WHERE custom_fields @> '{"device": {"os": "iOS"}}';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM ticket
WHERE search_tsv @@ websearch_to_tsquery('english', 'export');

SELECT pg_size_pretty(pg_relation_size('ticket_custom_fields_gin')) AS gin_docs,
       pg_size_pretty(pg_relation_size('ticket_search_idx'))        AS gin_search;
