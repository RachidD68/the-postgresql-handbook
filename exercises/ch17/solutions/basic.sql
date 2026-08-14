-- Solution to Exercise 17.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 17,
--              then the chapter's own role/grant/RLS listings
--              (mirrored by schema/migrations/090-ch17-security.sql).

CREATE ROLE dashboard_viewer NOLOGIN;
GRANT USAGE ON SCHEMA lumina TO dashboard_viewer;
GRANT SELECT ON v_agent_workload TO dashboard_viewer;

SET ROLE dashboard_viewer;
SELECT count(*) FROM v_agent_workload;   -- answers: 30
SELECT count(*) FROM v_open_ticket;
-- ERROR:  permission denied for view v_open_ticket     (42501)
SELECT count(*) FROM ticket;
-- ERROR:  permission denied for table ticket           (42501)
RESET ROLE;

-- All three behaviors are correct, and both refusals are the same 42501:
-- a view is just another object with its own ACL, so not granting
-- v_open_ticket is exactly the same denial as not granting the table.
-- The granted view answers because the VIEW's owner (postgres) is who the
-- base-table access is checked against — the permission boundary at work.

-- Cleanup (roles are cluster-level; the reset script does not know this one):
DROP OWNED BY dashboard_viewer;
DROP ROLE dashboard_viewer;
