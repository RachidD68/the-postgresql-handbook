-- Solution to Exercise 1.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 1

-- Inspect the catalog table first:
--   \d pg_database
-- Two columns whose purpose the names give away: datname (the database's
-- name) and datallowconn (whether connections are allowed).
SELECT datname, datallowconn
FROM pg_database
ORDER BY datname;
