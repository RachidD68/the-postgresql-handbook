-- Listing 15.19 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX event_occurred_brin ON ticket_event USING brin (occurred_at);

CREATE INDEX event_occurred_btree_demo ON ticket_event (occurred_at);

SELECT pg_size_pretty(pg_relation_size('event_occurred_brin'))       AS brin,
       pg_size_pretty(pg_relation_size('event_occurred_btree_demo')) AS btree;

DROP INDEX event_occurred_btree_demo;
