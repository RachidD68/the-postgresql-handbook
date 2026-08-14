-- Solution to Exercise 11.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 11,
--              then sql/ch11/11-08 and 11-10 (the chapter's custom_fields).

BEGIN;

-- Blast radius first:
SELECT count(*)
FROM ticket AS t
JOIN customer AS c ON c.id = t.customer_id
WHERE t.status = 'open' AND c.plan = 'enterprise';
-- 3 tickets.

-- || merges at the top level without disturbing existing keys:
UPDATE ticket AS t
SET custom_fields = custom_fields || '{"beta_notes": true}'
FROM customer AS c
WHERE c.id = t.customer_id
  AND c.plan = 'enterprise'
  AND t.status = 'open';
-- UPDATE 3 — matches the count. Proceed.

-- One affected document (existing keys intact, flag added):
SELECT reference, custom_fields
FROM ticket
WHERE reference = 'LUM-1031';

-- One untouched document (open, but customer is on the pro plan):
SELECT reference, custom_fields
FROM ticket
WHERE reference = 'LUM-1040';

ROLLBACK;
