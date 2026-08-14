-- Solution to Exercise 18.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 18
-- (Shell exercise; commands below, findings as comments.)

-- 1. The surgical dump (2.7 MB for 80,040 rows, custom format):
--      pg_dump -Fc -t lumina.ticket -d lumina -f ticket.dump

-- 2. The table of contents, BEFORE committing to a restore:
--      pg_restore -l ticket.dump
--    lists 35 TOC entries: the table, its data, indexes, triggers,
--    policies, grants — and nothing else.

-- 3. The scratch restore:
--      psql -c "CREATE DATABASE lumina_scratch"
--      psql -d lumina_scratch -c "CREATE SCHEMA lumina"
--      pg_restore -d lumina_scratch ticket.dump
--    First attempt fails HARD at CREATE TABLE:
--      ERROR: type "lumina.ticket_priority" does not exist
--    — a -t dump carries the table, not the schema, and not the enum TYPE
--    the priority column depends on. That first error is the lesson.
--    Pre-create both:
--      CREATE SCHEMA lumina;
--      CREATE TYPE lumina.ticket_priority AS ENUM
--          ('low', 'normal', 'high', 'urgent');
--    and the restore lands the data with 5 ignorable post-data grumbles:
--    two trigger functions and three FK targets (agent, customer, team)
--    that did not come along.

-- 4. The verification:
--      SELECT count(*) FROM lumina.ticket;   -- 80040. Match.

-- What the restored database did NOT get: the referenced tables, the
-- trigger functions, the enum (until we made one), or any other table —
-- a -t dump is surgical, which is both its use and its trap.
