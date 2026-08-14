-- Solution to Exercise 3.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 3

INSERT INTO tag (name, description)
VALUES ('data-import', 'Bulk and file-based imports into the product')
RETURNING id, name;
-- Returns id 21: the seed's twenty tags end at 20.

DELETE FROM tag
WHERE name = 'data-import'
RETURNING id, name;
-- The removal reports what it removed: (21, data-import), DELETE 1.
