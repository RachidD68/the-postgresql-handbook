-- Listing 15.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE TABLE ticket_scratch AS SELECT * FROM ticket WHERE false;

\timing on
INSERT INTO ticket_scratch SELECT * FROM ticket;   -- bare

CREATE INDEX s1 ON ticket_scratch (customer_id);
CREATE INDEX s2 ON ticket_scratch (team_id, status);
CREATE INDEX s3 ON ticket_scratch (assigned_agent_id);
CREATE INDEX s4 ON ticket_scratch (created_at);
CREATE INDEX s5 ON ticket_scratch (lower(subject));
CREATE INDEX s6 ON ticket_scratch USING gin (custom_fields);

TRUNCATE ticket_scratch;
INSERT INTO ticket_scratch SELECT * FROM ticket;   -- indexed
\timing off

DROP TABLE ticket_scratch;
