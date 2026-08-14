-- Solution to Exercise 5.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 5,
--              then sql/ch05/05-14-create-enum.sql and 05-15-alter-using.sql
--              (the chapter's own enum conversion).

-- Inside a transaction, the new value exists but cannot be used yet:
BEGIN;
ALTER TYPE ticket_priority ADD VALUE 'critical' AFTER 'urgent';
SELECT enum_range(NULL::ticket_priority);   -- shows critical already
SELECT 'critical'::ticket_priority;
-- ERROR:  unsafe use of new value "critical" of enum type ticket_priority
-- HINT:   New enum values must be committed before they can be used.
ROLLBACK;

-- Committed, it works — and is now permanent, because there is no
-- ALTER TYPE ... DROP VALUE. The removal is a four-step migration:
ALTER TYPE ticket_priority ADD VALUE 'critical' AFTER 'urgent';
SELECT enum_range(NULL::ticket_priority);
-- {low,normal,high,urgent,critical}

-- 1. New type with the surviving values.
CREATE TYPE ticket_priority_new AS ENUM ('low', 'normal', 'high', 'urgent');
-- 2. Migrate the column, folding the doomed value into a survivor.
ALTER TABLE ticket
    ALTER COLUMN priority TYPE ticket_priority_new
    USING (CASE WHEN priority::text = 'critical' THEN 'urgent'
                ELSE priority::text
           END)::ticket_priority_new;
-- 3 and 4. Drop the old type; take back the name.
DROP TYPE ticket_priority;
ALTER TYPE ticket_priority_new RENAME TO ticket_priority;

SELECT enum_range(NULL::ticket_priority);
-- {low,normal,high,urgent}

-- The property a value set must have before enum is the right bet: it is
-- CLOSED — additions rare and append-only, removals unimaginable. Priorities
-- qualify; anything product iterates on (payment states, plans) does not.
