-- Solution to Exercise 14.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 14

SELECT count(*) FROM tag;   -- 20 before

BEGIN;

SAVEPOINT tag_1;
INSERT INTO tag (name, description)
VALUES ('follow-up', 'Needs a scheduled follow-up touch');
-- Succeeds; the savepoint is released by moving on.

SAVEPOINT tag_2;
INSERT INTO tag (name, description)
VALUES ('billing', 'Charges and payment methods');
-- ERROR: duplicate key value violates unique constraint "tag_name_key"
ROLLBACK TO SAVEPOINT tag_2;
-- The transaction is alive again; only the duplicate is gone.

SAVEPOINT tag_3;
INSERT INTO tag (name, description)
VALUES ('escalated', 'Raised beyond first-line support');

COMMIT;

-- Exactly two arrived: 22.
SELECT count(*) FROM tag;
SELECT name FROM tag WHERE name IN ('follow-up', 'billing', 'escalated')
ORDER BY name;

-- The cost to file against Chapter 18: every SAVEPOINT is a round trip and
-- a subtransaction. A savepoint per row is fine for tens of rows and poison
-- for millions — bulk loads stage into a scratch table instead.
