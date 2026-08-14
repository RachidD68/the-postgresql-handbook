-- Solution to Exercise 1.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 1

-- List the databases, then connect to lumina (psql meta-commands):
--   \l
--   \c lumina

-- Three questions, three one-line SELECTs:
SELECT version();

SELECT now();

SELECT current_database();
