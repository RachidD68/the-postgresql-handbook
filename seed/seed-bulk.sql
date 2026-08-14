-- The PostgreSQL Handbook — bulk seed for the performance chapters (15+)
--
-- Adds ~800 customers, 24 agents, 80,000 tickets, and ~500,000 events on top of
-- seed-core.sql, so that Chapters 15-20 make honest points about indexes, plans,
-- and partitioning. At core-seed volume the planner would (correctly) never leave
-- a sequential scan.
--
-- DETERMINISM: every value derives from generate_series + prime-modulus
-- arithmetic — no random(), no now(). The same file produces byte-identical data
-- on any PostgreSQL version, which is what lets the book print captured EXPLAIN
-- output. setseed() is called anyway as a belt-and-braces guard: if random()
-- ever sneaks in, it at least stays reproducible on 18.x.
--
-- Timeline: tickets span 2025-07-01 .. 2026-01-14 (about 6.5 months), giving
-- Chapter 19 a natural month-by-month partitioning story.

SELECT setseed(0.42);

-- ── 800 bulk customers (ids 101-900) ───────────────────────────────
INSERT INTO lumina.customer (id, company_name, full_name, email, plan, signed_up_at)
    OVERRIDING SYSTEM VALUE
SELECT
    100 + n,
    'Company ' || lpad(n::text, 3, '0'),
    'Contact ' || lpad(n::text, 3, '0'),
    'contact' || n || '@company' || n || '.example',
    CASE WHEN n % 10 < 5 THEN 'free' WHEN n % 10 < 8 THEN 'pro' ELSE 'enterprise' END,
    timestamptz '2024-01-01 00:00+00' + ((n * 613) % 700) * interval '1 day'
FROM generate_series(1, 800) AS n;

-- ── 24 bulk agents (ids 101-124), 8 per team ───────────────────────
-- Team assignment: ((id - 101) % 3) + 1. Managers are the core team leads.
INSERT INTO lumina.agent (id, team_id, manager_id, full_name, email, hired_on)
    OVERRIDING SYSTEM VALUE
SELECT
    100 + n,
    ((n - 1) % 3) + 1,
    CASE ((n - 1) % 3) + 1 WHEN 1 THEN 3 WHEN 2 THEN 1 ELSE 5 END,
    'Agent ' || lpad(n::text, 2, '0'),
    'agent' || n || '@lumina.example',
    date '2024-01-01' + ((n * 47) % 500)
FROM generate_series(1, 24) AS n;

-- ── 80,000 tickets (ids 1001-81000, references LUM-1041..LUM-81040) ─
-- The CTE computes each ticket's derived facts once; the outer SELECT shapes them.
-- Distributions: teams 30/50/20 (billing/tech/onboarding); priorities 5/20/50/25
-- (urgent/high/normal/low); recent tickets skew open, older ones closed.
INSERT INTO lumina.ticket (id, reference, customer_id, assigned_agent_id, team_id, subject, body,
    status, priority, channel, created_at, first_response_at, resolved_at, closed_at, satisfaction)
    OVERRIDING SYSTEM VALUE
SELECT
    1000 + f.n,
    'LUM-' || (1040 + f.n),
    f.cust,
    CASE WHEN s.status = 'open' AND f.h % 33 = 0 THEN NULL ELSE s.agent END,
    f.team,
    f.subj || ' — case ' || f.n,
    f.subj || '. Reported by ' || f.chan || ' and tracked as case ' || f.n
           || '. Reproduction details and environment notes follow in the thread.',
    s.status,
    f.prio::lumina.ticket_priority,
    f.chan,
    f.created,
    CASE WHEN s.status = 'open' AND f.h % 33 = 0 THEN NULL
         ELSE f.created + s.fr_minutes * interval '1 minute' END,
    CASE WHEN s.status IN ('resolved', 'closed')
         THEN f.created + (4 + f.h % 96) * interval '1 hour' END,
    CASE WHEN s.status = 'closed'
         THEN f.created + (52 + f.h % 96) * interval '1 hour' END,
    CASE WHEN s.status = 'closed' AND f.h % 3 <> 0
         THEN (ARRAY[5,5,5,4,4,4,5,3,2,1])[1 + (f.h * 11) % 10]::smallint END
FROM (
    SELECT
        n,
        ((n::bigint * 104729 + 12345) % 100)::int                    AS h,
        CASE WHEN (n * 7919) % 10 < 3 THEN 1
             WHEN (n * 7919) % 10 < 8 THEN 2 ELSE 3 END              AS team,
        CASE WHEN n % 40 = 0 THEN 1 + (n / 40) % 12
             ELSE 101 + (n * 7919) % 800 END                          AS cust,
        CASE WHEN (n * 31) % 20 < 1  THEN 'urgent'
             WHEN (n * 31) % 20 < 5  THEN 'high'
             WHEN (n * 31) % 20 < 15 THEN 'normal' ELSE 'low' END    AS prio,
        (ARRAY['email','email','email','email','web','web','web',
               'chat','chat','phone'])[1 + (n * 13) % 10]            AS chan,
        (ARRAY['Cannot sign in to workspace', 'Invoice question', 'API request rejected',
               'Export never finishes', 'Page loads slowly', 'Webhook delivery failed',
               'Mobile app misbehaves', 'Billing address change', 'Integration disconnected',
               'Feature question', 'Email notifications missing',
               'Access denied unexpectedly'])[1 + n % 12]            AS subj,
        timestamptz '2025-07-01 00:00+00'
            + n * interval '212 seconds'
            + ((n * 7919) % 97) * interval '1 minute'                AS created
    FROM generate_series(1, 80000) AS n
) AS f
CROSS JOIN LATERAL (
    SELECT
        CASE
            WHEN f.n > 74000 THEN   -- the most recent ~2 weeks: mostly still in flight
                CASE WHEN f.h < 25 THEN 'closed' WHEN f.h < 40 THEN 'resolved'
                     WHEN f.h < 65 THEN 'waiting_on_customer' ELSE 'open' END
            ELSE                    -- older tickets: overwhelmingly done
                CASE WHEN f.h < 72 THEN 'closed' WHEN f.h < 88 THEN 'resolved'
                     WHEN f.h < 94 THEN 'waiting_on_customer' ELSE 'open' END
        END AS status,
        CASE WHEN f.n % 25 = 0 THEN
            CASE f.team WHEN 1 THEN 3 WHEN 2 THEN 1 ELSE 5 END       -- core leads keep a hand in
        ELSE
            101 + (f.team - 1) + 3 * ((f.n * 31) % 8)                -- bulk agent on the same team
        END AS agent,
        CASE f.prio WHEN 'urgent' THEN 10 + f.h % 25
                    WHEN 'high'   THEN 25 + f.h % 60
                    WHEN 'normal' THEN 45 + f.h % 300
                    ELSE               90 + f.h % 600 END            AS fr_minutes
) AS s(status, agent, fr_minutes);

-- ── Tags: one or two per bulk ticket ───────────────────────────────
INSERT INTO lumina.ticket_tag (ticket_id, tag_id)
SELECT 1000 + n, 1 + (n * 17) % 20
FROM generate_series(1, 80000) AS n
ON CONFLICT DO NOTHING;

INSERT INTO lumina.ticket_tag (ticket_id, tag_id)
SELECT 1000 + n, 1 + (n * 23) % 20
FROM generate_series(1, 80000) AS n
WHERE n % 3 = 0
ON CONFLICT DO NOTHING;

-- ── Events: ~520,000 rows ──────────────────────────────────────────
-- Structural events mirror seed-core; activity events add 1-5 more per ticket.
INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'created', jsonb_build_object('channel', channel, 'priority', priority), created_at
FROM lumina.ticket WHERE id > 1000;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'assigned', jsonb_build_object('agent_id', assigned_agent_id), created_at + interval '15 minutes'
FROM lumina.ticket WHERE id > 1000 AND assigned_agent_id IS NOT NULL;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'status_changed', jsonb_build_object('from', 'open', 'to', 'resolved'), resolved_at
FROM lumina.ticket WHERE id > 1000 AND resolved_at IS NOT NULL;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'status_changed', jsonb_build_object('from', 'resolved', 'to', 'closed'), closed_at
FROM lumina.ticket WHERE id > 1000 AND closed_at IS NOT NULL;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT
    t.id,
    (ARRAY['viewed', 'comment_added', 'priority_reviewed', 'note_added'])[1 + (t.id * e) % 4],
    jsonb_build_object('seq', e),
    t.created_at + e * interval '37 minutes'
FROM lumina.ticket AS t
CROSS JOIN LATERAL generate_series(1, 1 + t.id % 5) AS e
WHERE t.id > 1000;

-- ── Re-sync sequences ──────────────────────────────────────────────
SELECT setval(pg_get_serial_sequence('lumina.customer', 'id'), (SELECT max(id) FROM lumina.customer));
SELECT setval(pg_get_serial_sequence('lumina.agent', 'id'),    (SELECT max(id) FROM lumina.agent));
SELECT setval(pg_get_serial_sequence('lumina.ticket', 'id'),   (SELECT max(id) FROM lumina.ticket));
