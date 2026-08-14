-- Solution to Exercise 17.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 17,
--              then the chapter's own role/grant/RLS listings
--              (mirrored by schema/migrations/090-ch17-security.sql).

-- Recreate the predecessor's damage:
GRANT ALL ON ALL TABLES IN SCHEMA lumina TO lumina_readonly;

-- The audit: every table crossed with every privilege of interest.
SELECT t.tablename, p.privilege
FROM pg_tables AS t
CROSS JOIN unnest(ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE'])
    AS p(privilege)
WHERE t.schemaname = 'lumina'
  AND has_table_privilege('lumina_readonly',
                          t.schemaname || '.' || t.tablename,
                          p.privilege)
ORDER BY t.tablename, p.privilege;
-- 44 rows: all four privileges on all eleven base tables — a "readonly"
-- role that can DELETE the audit trail.

-- The repair: rebuild the small truth instead of subtracting the large lie.
REVOKE ALL ON ALL TABLES IN SCHEMA lumina FROM lumina_readonly;
GRANT SELECT ON v_open_ticket, v_agent_workload TO lumina_readonly;

-- Re-run the audit: 0 rows. (Views live in pg_views, not pg_tables — the
-- base-table surface is clean, and the two views are the role's whole world.)
