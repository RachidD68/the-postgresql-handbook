-- Migration 020 (Chapter 5) — the priority column becomes an enum.
--
-- Chapter 5's worked migration: ticket.priority converts from text to a real
-- ticket_priority enum ON A POPULATED TABLE, via ALTER ... USING. Declaration
-- order IS the sort order — that is the point of the exercise (Chapter 4's
-- CASE workaround retires). status deliberately STAYS text: Chapter 6 guards
-- it with a CHECK constraint instead, so the book shows both strategies side
-- by side on the same table.
--
-- Matches listings 05-14 and 05-15 in Book/chapters/Ch05 exactly (bare names,
-- resolved by the database-pinned search_path, per Appendix C rule 11).

CREATE TYPE ticket_priority AS ENUM ('low', 'normal', 'high', 'urgent');

ALTER TABLE ticket
    ALTER COLUMN priority TYPE ticket_priority
    USING priority::ticket_priority;
