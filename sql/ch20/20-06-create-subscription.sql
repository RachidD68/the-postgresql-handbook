-- Listing 20.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch20/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 20
\c lumina

SELECT pg_create_logical_replication_slot('lumina_sub', 'pgoutput');

\c lumina_replica

CREATE SUBSCRIPTION lumina_sub
    CONNECTION 'host=localhost dbname=lumina user=postgres'
    PUBLICATION lumina_pub
    WITH (create_slot = false, slot_name = 'lumina_sub');

-- When you are done watching rows arrive, tear the demo down in this
-- order: the subscription owns the slot, so it goes first.
-- DROP SUBSCRIPTION lumina_sub;
-- \c lumina
-- DROP PUBLICATION lumina_pub;
