-- 060-ch13-programmables.sql — Chapter 13's work product, applied from Chapter 14 onward.
-- Mirrors listings 13-01, 13-04, 13-08, 13-12, 13-13, 13-21, and 13-24 (the book's
-- listings ARE the source; this file replays them so State(N >= 14) matches a
-- reader who followed Ch13). Not shipped: the archive procedure and its scratch
-- tables (self-cleaning in-chapter), fn_resolution_summary, and the
-- v_urgent_ticket fragment demo. NOTE: reset-to-chapter re-runs REFRESH
-- MATERIALIZED VIEW after seeding, because this file executes against an
-- empty ticket table.

-- ── Views ──────────────────────────────────────────────────────────
CREATE VIEW lumina.v_open_ticket AS
SELECT t.id, t.reference, t.subject, c.company_name,
       tm.name AS team, a.full_name AS agent,
       t.priority, t.created_at
FROM lumina.ticket AS t
JOIN lumina.customer AS c ON c.id = t.customer_id
JOIN lumina.team AS tm ON tm.id = t.team_id
LEFT JOIN lumina.agent AS a ON a.id = t.assigned_agent_id
WHERE t.status = 'open';

CREATE VIEW lumina.v_agent_workload AS
SELECT a.id, a.full_name, tm.name AS team,
       count(t.id) FILTER (WHERE t.status = 'open') AS open_tickets,
       count(t.id) AS assigned_ever
FROM lumina.agent AS a
JOIN lumina.team AS tm ON tm.id = a.team_id
LEFT JOIN lumina.ticket AS t ON t.assigned_agent_id = a.id
GROUP BY a.id, a.full_name, tm.name;

-- ── Materialized view (the Ch8 dashboard / Ch10 trend, cached) ─────
CREATE MATERIALIZED VIEW lumina.mv_monthly_stats AS
SELECT date_trunc('month', created_at)::date AS month_of,
       count(*) AS filed,
       count(*) FILTER (WHERE priority IN ('urgent', 'high')) AS hot,
       count(resolved_at) AS resolved,
       round(avg(resolution_minutes), 0) AS avg_resolution
FROM lumina.ticket
GROUP BY month_of
ORDER BY month_of;

-- REFRESH CONCURRENTLY requires a unique index.
CREATE UNIQUE INDEX mv_monthly_stats_month_idx
    ON lumina.mv_monthly_stats (month_of);

-- ── SQL function ───────────────────────────────────────────────────
-- as_of defaults to the live clock; the book passes its fixed anchor in
-- captured listings so printed output stays deterministic.
CREATE FUNCTION lumina.fn_ticket_age(t_id bigint, as_of timestamptz DEFAULT now())
RETURNS interval
LANGUAGE sql
AS $$
    SELECT as_of - created_at
    FROM lumina.ticket
    WHERE id = t_id;
$$;

-- ── updated_at + touch trigger ─────────────────────────────────────
-- Nullable on purpose: NULL means "never modified since the column arrived,"
-- which keeps the backfill deterministic and the meaning honest.
ALTER TABLE lumina.ticket
    ADD COLUMN updated_at timestamptz;

CREATE FUNCTION lumina.touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER ticket_touch_updated_at
    BEFORE UPDATE ON lumina.ticket
    FOR EACH ROW
    EXECUTE FUNCTION lumina.touch_updated_at();

-- ── Audit trigger: status changes write the event trail ────────────
CREATE FUNCTION lumina.log_status_change()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
    VALUES (NEW.id, 'status_changed',
            jsonb_build_object('from', OLD.status, 'to', NEW.status),
            now());
    RETURN NEW;
END;
$$;

CREATE TRIGGER ticket_audit_status
    AFTER UPDATE OF status ON lumina.ticket
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION lumina.log_status_change();
