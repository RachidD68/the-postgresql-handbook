-- Listing 20.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch20/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 20
-- in lumina (the publisher), BEFORE subscribing:
SELECT pg_create_logical_replication_slot('lumina_sub', 'pgoutput');

-- in lumina_replica:
CREATE SUBSCRIPTION lumina_sub
    CONNECTION 'host=localhost dbname=lumina user=postgres'
    PUBLICATION lumina_pub
    WITH (create_slot = false, slot_name = 'lumina_sub');
