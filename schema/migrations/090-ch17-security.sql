-- 090-ch17-security.sql — Chapter 17's work product, applied from Chapter 18 onward.
-- Mirrors the chapter's role/grant/RLS listings (the book's listings ARE the
-- source). One mechanical difference, logged: roles are CLUSTER-level and
-- survive the database drop each reset performs, so creations here are guarded
-- for idempotence; the book's listings show the plain first-time CREATE ROLE.
-- The book's LOGIN + password discussion is prose-only: the repo ships NOLOGIN
-- roles and never stores a password.

DO $$ BEGIN CREATE ROLE lumina_app NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE lumina_readonly NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE support_agent NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ── Schema access: nothing by default, then exactly enough ─────────
REVOKE ALL ON SCHEMA lumina FROM PUBLIC;
GRANT USAGE ON SCHEMA lumina TO lumina_app, lumina_readonly, support_agent;

-- ── Least privilege for the application account ────────────────────
GRANT SELECT, INSERT, UPDATE
    ON lumina.ticket, lumina.ticket_comment, lumina.ticket_event
    TO lumina_app;
GRANT SELECT
    ON lumina.customer, lumina.agent, lumina.team,
       lumina.tag, lumina.ticket_tag, lumina.sla_policy, lumina.ticket_job
    TO lumina_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA lumina TO lumina_app;

-- Future tables inherit the same shape without a human remembering.
ALTER DEFAULT PRIVILEGES IN SCHEMA lumina
    GRANT SELECT, INSERT, UPDATE ON TABLES TO lumina_app;

-- ── The reporting role sees views, never base tables ───────────────
GRANT SELECT ON lumina.v_open_ticket, lumina.v_agent_workload TO lumina_readonly;

-- ── Column-level grant: the one honest example ─────────────────────
GRANT SELECT (id, reference, subject, status, priority)
    ON lumina.ticket TO support_agent;

-- ── Row-Level Security: tenancy the database never forgets ─────────
ALTER TABLE lumina.ticket ENABLE ROW LEVEL SECURITY;
ALTER TABLE lumina.ticket FORCE ROW LEVEL SECURITY;

CREATE POLICY customer_isolation ON lumina.ticket
    TO lumina_app
    USING (customer_id = current_setting('app.customer_id', true)::bigint)
    WITH CHECK (customer_id = current_setting('app.customer_id', true)::bigint);

-- Staff tooling sees every row; policies are additive by audience.
CREATE POLICY staff_full_access ON lumina.ticket
    TO support_agent
    USING (true);

-- ── SECURITY DEFINER, hardened ─────────────────────────────────────
CREATE FUNCTION lumina.fn_my_tickets()
RETURNS TABLE (reference text, subject text, status text)
LANGUAGE sql
SECURITY DEFINER
SET search_path = lumina, pg_temp
AS $$
    SELECT reference, subject, status
    FROM ticket
    WHERE customer_id = current_setting('app.customer_id', true)::bigint
    ORDER BY reference;
$$;

-- Functions get EXECUTE granted to PUBLIC by default; a DEFINER function
-- names its callers (the chapter's standard second hardening step).
REVOKE EXECUTE ON FUNCTION lumina.fn_my_tickets() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION lumina.fn_my_tickets() TO lumina_app;
