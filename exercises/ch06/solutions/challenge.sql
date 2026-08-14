-- Solution to Exercise 6.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 6

-- "Closed implies resolved" in SQL is NOT A OR B:
ALTER TABLE ticket
    ADD CONSTRAINT ticket_closed_implies_resolved
        CHECK (status <> 'closed' OR resolved_at IS NOT NULL)
        NOT VALID;

ALTER TABLE ticket VALIDATE CONSTRAINT ticket_closed_implies_resolved;
-- Validates cleanly against all forty tickets.

-- Why every row passed — and why none needed the UNKNOWN-passes loophole:
-- status is NOT NULL, so status <> 'closed' is always TRUE or FALSE, never
-- UNKNOWN; and IS NOT NULL is a predicate that never returns UNKNOWN at all.
-- Every non-closed ticket lands a clean TRUE on the left disjunct, every
-- closed ticket a clean TRUE on the right (the seed closes nothing without
-- resolving it first) — unlike the satisfaction CHECK, where NULL scores
-- pass only because CHECK treats UNKNOWN as success.
