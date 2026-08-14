-- The PostgreSQL Handbook — Lumina Helpdesk core seed (Chapter 3)
--
-- Deterministic and hand-written: fixed ids, fixed timestamps, no random(), no
-- now(). The book's "today" is anchored at 2026-01-15 09:00:00+00; every printed
-- result grid in Chapters 3-14 comes from exactly these rows, so every row here
-- is nameable in prose ("Fiona O'Brien's VAT ticket", "the Monday-morning
-- dashboard ticket").
--
-- Explicit ids use OVERRIDING SYSTEM VALUE; the sequences are re-synced at the
-- bottom so the reader's own INSERTs in Chapter 3 get clean ids (41+, 121+, ...).

-- ── Teams ──────────────────────────────────────────────────────────
INSERT INTO lumina.team (id, name, focus_area, created_at) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Billing',           'Invoices, payments, refunds, plan changes', '2024-02-01 09:00+00'),
    (2, 'Technical Support', 'Product defects, APIs, integrations',       '2024-02-01 09:00+00'),
    (3, 'Onboarding',        'New-customer setup and training',           '2024-06-15 09:00+00');

-- ── Agents (manager_id builds the Chapter 7 self-join) ─────────────
INSERT INTO lumina.agent (id, team_id, manager_id, full_name, email, hired_on) OVERRIDING SYSTEM VALUE VALUES
    (1, 2, NULL, 'Priya Nair',   'priya.nair@lumina.example',   '2021-03-15'),
    (2, 2, 1,    'Marcus Webb',  'marcus.webb@lumina.example',  '2022-08-01'),
    (3, 1, NULL, 'Sofia Ramos',  'sofia.ramos@lumina.example',  '2020-06-10'),
    (4, 1, 3,    'Dmitri Volkov','dmitri.volkov@lumina.example','2023-02-20'),
    (5, 3, NULL, 'Amara Diallo', 'amara.diallo@lumina.example', '2021-11-08'),
    (6, 2, 1,    'Leo Tanaka',   'leo.tanaka@lumina.example',   '2024-05-12');

-- ── Customers (note Fiona O'Brien — the doubled-quote lesson) ──────
INSERT INTO lumina.customer (id, company_name, full_name, email, plan, signed_up_at) OVERRIDING SYSTEM VALUE VALUES
    (1,  'Harbor Analytics',  'Fiona O''Brien',  'fiona@harboranalytics.example', 'pro',        '2024-03-11 14:20+00'),
    (2,  'Northwind Traders', 'Jack Chen',       'jack.chen@northwind.example',   'enterprise', '2024-01-29 10:05+00'),
    (3,  'Bluebird Bakery',   'Rosa Delgado',    'rosa@bluebirdbakery.example',   'free',       '2024-09-02 08:45+00'),
    (4,  'Meridian Logistics','Tom Okafor',      'tokafor@meridianlog.example',   'enterprise', '2024-02-14 16:30+00'),
    (5,  'Quartz Media',      'Elena Petrova',   'elena@quartzmedia.example',     'pro',        '2024-05-21 11:10+00'),
    (6,  'Cascade Outdoors',  'Sam Whitfield',   'sam@cascadeoutdoors.example',   'free',       '2024-11-30 19:55+00'),
    (7,  'Beacon Health',     'Aisha Rahman',    'arahman@beaconhealth.example',  'enterprise', '2024-04-08 09:15+00'),
    (8,  'Atelier Moreau',    'Lucas Moreau',    'lucas@ateliermoreau.example',   'free',       '2025-01-17 13:40+00'),
    (9,  'Pinecrest Software','Grace Kim',       'grace@pinecrest.example',       'pro',        '2024-07-03 15:25+00'),
    (10, 'Solstice Energy',   'Diego Fuentes',   'dfuentes@solstice.example',     'pro',        '2024-08-19 10:50+00'),
    (11, 'Fjord Consulting',  'Nina Haugen',     'nina@fjordconsulting.example',  'free',       '2025-02-25 12:00+00'),
    (12, 'Crescent Foods',    'Omar Haddad',     'ohaddad@crescentfoods.example', 'enterprise', '2024-06-27 08:30+00');

-- ── Tags ───────────────────────────────────────────────────────────
INSERT INTO lumina.tag (id, name, description) OVERRIDING SYSTEM VALUE VALUES
    (1,  'login',           'Sign-in, SSO, and session problems'),
    (2,  'billing',         'Charges, plans, and payment methods'),
    (3,  'invoice',         'Invoice contents and delivery'),
    (4,  'refund',          'Refund requests and status'),
    (5,  'api',             'REST API behavior and limits'),
    (6,  'webhook',         'Outbound webhook delivery'),
    (7,  'mobile',          'iOS and Android apps'),
    (8,  'crash',           'Hard failures and error screens'),
    (9,  'performance',     'Slowness and timeouts'),
    (10, 'feature-request', 'Requests for new functionality'),
    (11, 'how-to',          'Usage questions'),
    (12, 'data-export',     'Exports and downloads'),
    (13, 'integration',     'Third-party integrations'),
    (14, 'security',        'Auth, 2FA, and access control'),
    (15, 'outage',          'Service unavailability'),
    (16, 'email-delivery',  'Outbound email problems'),
    (17, 'onboarding',      'Setup and first-run experience'),
    (18, 'upgrade',         'Plan upgrades and proration'),
    (19, 'documentation',   'Docs gaps and corrections'),
    (20, 'printer',         'Print layouts and printer-friendly views');

-- ── Tickets (Nov 3, 2025 – Jan 14, 2026; "today" is Jan 15, 09:00) ─
-- Status mix: 17 closed, 9 resolved, 7 waiting_on_customer, 7 open.
-- Tickets 36 and 39 are unassigned with no first response yet — the NULLs are
-- load-bearing for Chapter 4.
INSERT INTO lumina.ticket (id, reference, customer_id, assigned_agent_id, team_id, subject, body,
    status, priority, channel, created_at, first_response_at, resolved_at, closed_at, satisfaction)
    OVERRIDING SYSTEM VALUE VALUES
    (1,  'LUM-1001', 2,  1,    2, 'API returns 429 for batch export',        'Our nightly export job started failing with 429 Too Many Requests around 2am.', 'resolved', 'high',   'email', '2025-11-03 08:14+00', '2025-11-03 09:02+00', '2025-11-04 15:30+00', NULL, 4),
    (2,  'LUM-1002', 3,  5,    3, 'Cannot finish onboarding checklist',      'The last step of the setup checklist stays grayed out no matter what I do.',    'closed',   'low',    'web',   '2025-11-04 10:22+00', '2025-11-04 16:45+00', '2025-11-05 11:00+00', '2025-11-07 09:00+00', 4),
    (3,  'LUM-1003', 1,  3,    1, 'Invoice shows wrong VAT number',          'Our October invoice lists the old VAT registration; we updated it in September.','closed',   'normal', 'email', '2025-11-05 09:31+00', '2025-11-05 11:15+00', '2025-11-06 10:20+00', '2025-11-08 09:00+00', 5),
    (4,  'LUM-1004', 7,  2,    2, 'Mobile app crashes on photo upload',      'The Android app closes immediately when attaching a photo to a report.',       'closed',   'high',   'web',   '2025-11-06 14:05+00', '2025-11-06 14:40+00', '2025-11-10 17:00+00', '2025-11-12 09:00+00', 3),
    (5,  'LUM-1005', 5,  4,    1, 'Double-charged for November',             'Two identical charges hit our card on the 1st; we only have one subscription.','closed',   'urgent', 'phone', '2025-11-07 08:03+00', '2025-11-07 08:15+00', '2025-11-07 16:45+00', '2025-11-09 09:00+00', 2),
    (6,  'LUM-1006', 9,  1,    2, 'Webhook deliveries delayed 10 minutes',   'ticket.created webhooks arrive up to ten minutes late since last Thursday.',   'resolved', 'normal', 'email', '2025-11-10 11:47+00', '2025-11-10 13:20+00', '2025-11-13 10:00+00', NULL, NULL),
    (7,  'LUM-1007', 4,  6,    2, 'SSO login loops back to sign-in',         'After the IdP certificate rotation, SAML login bounces straight back.',        'closed',   'urgent', 'chat',  '2025-11-12 07:58+00', '2025-11-12 08:06+00', '2025-11-12 12:30+00', '2025-11-14 09:00+00', 5),
    (8,  'LUM-1008', 8,  5,    3, 'How do I import contacts from CSV?',      'I have 300 contacts in a spreadsheet and cannot find the import button.',      'closed',   'low',    'web',   '2025-11-13 15:12+00', '2025-11-14 10:00+00', '2025-11-14 10:30+00', '2025-11-16 09:00+00', 5),
    (9,  'LUM-1009', 10, 3,    1, 'Refund for cancelled seat not received',  'We removed two seats on Oct 28; the credit has not appeared on any invoice.',  'closed',   'high',   'email', '2025-11-17 09:40+00', '2025-11-17 10:25+00', '2025-11-19 14:00+00', '2025-11-21 09:00+00', 4),
    (10, 'LUM-1010', 6,  2,    2, 'Search returns no results after rename',  'Since renaming our workspace, global search finds nothing older than the rename.', 'resolved', 'normal', 'web', '2025-11-18 13:26+00', '2025-11-18 15:50+00', '2025-11-21 11:15+00', NULL, 5),
    (11, 'LUM-1011', 12, 4,    1, 'Enterprise invoice needs PO number',      'Accounts payable rejects invoices without our purchase order number.',         'closed',   'normal', 'email', '2025-11-19 10:15+00', '2025-11-19 14:30+00', '2025-11-20 09:45+00', '2025-11-22 09:00+00', 5),
    (12, 'LUM-1012', 2,  1,    2, 'Rate limit docs contradict behavior',     'Docs say 100 requests/min but we are throttled at 60 on the batch endpoint.',  'closed',   'low',    'email', '2025-11-20 16:08+00', '2025-11-21 09:30+00', '2025-11-24 10:00+00', '2025-11-26 09:00+00', 4),
    (13, 'LUM-1013', 11, 5,    3, 'Trial expired before we finished setup',  'Our two-week trial ended mid-migration; can we get an extension?',             'resolved', 'normal', 'chat',  '2025-11-24 09:55+00', '2025-11-24 10:12+00', '2025-11-24 13:00+00', NULL, 4),
    (14, 'LUM-1014', 7,  6,    2, 'Exported PDF is blank on second page',    'Any report longer than one page exports with an empty second page.',           'closed',   'normal', 'web',   '2025-11-25 11:33+00', '2025-11-25 14:00+00', '2025-11-28 16:20+00', '2025-11-30 09:00+00', NULL),
    (15, 'LUM-1015', 1,  3,    1, 'Updating card details fails with 402',    'Replacing our expiring card returns error 402 on every attempt.',              'closed',   'high',   'web',   '2025-11-26 08:47+00', '2025-11-26 09:10+00', '2025-11-26 15:30+00', '2025-11-28 09:00+00', 3),
    (16, 'LUM-1016', 4,  2,    2, 'Dashboard slow every Monday morning',     'Loading the main dashboard takes 30+ seconds on Monday mornings only.',        'resolved', 'high',   'email', '2025-12-01 09:12+00', '2025-12-01 10:05+00', '2025-12-05 17:00+00', NULL, NULL),
    (17, 'LUM-1017', 9,  1,    2, 'Need staging environment API keys',       'We are building a CI pipeline and need separate keys for staging.',            'closed',   'low',    'email', '2025-12-02 14:29+00', '2025-12-03 09:15+00', '2025-12-03 11:40+00', '2025-12-05 09:00+00', 5),
    (18, 'LUM-1018', 3,  5,    3, 'Where is the keyboard shortcuts list?',   'I saw a shortcuts overlay once and can never find it again.',                  'closed',   'low',    'chat',  '2025-12-03 10:18+00', '2025-12-03 10:26+00', '2025-12-03 10:45+00', '2025-12-05 09:00+00', 4),
    (19, 'LUM-1019', 10, 4,    1, 'Proration on upgrade looks wrong',        'Upgrading from pro to enterprise mid-cycle charged more than the calculator showed.', 'resolved', 'normal', 'email', '2025-12-04 15:44+00', '2025-12-05 09:20+00', '2025-12-08 14:15+00', NULL, 3),
    (20, 'LUM-1020', 12, 6,    2, 'Emails to customers land in spam',        'Notification emails from our workspace are flagged as spam by Outlook.',       'resolved', 'urgent', 'email', '2025-12-08 08:21+00', '2025-12-08 08:50+00', '2025-12-12 16:00+00', NULL, 5),
    (21, 'LUM-1021', 5,  3,    1, 'Annual plan quote for 40 seats',          'Please send a formal quote for 40 seats on the annual enterprise plan.',       'closed',   'normal', 'email', '2025-12-09 11:02+00', '2025-12-09 15:30+00', '2025-12-10 10:00+00', '2025-12-12 09:00+00', 5),
    (22, 'LUM-1022', 8,  2,    2, 'Password reset link expired instantly',   'The reset email arrives but the link says expired within a minute.',           'closed',   'normal', 'chat',  '2025-12-10 09:38+00', '2025-12-10 09:55+00', '2025-12-11 12:20+00', '2025-12-13 09:00+00', NULL),
    (23, 'LUM-1023', 6,  5,    3, 'Team member cannot accept invite',        'The invite email for our new hire opens to a 404 page.',                       'resolved', 'normal', 'web',   '2025-12-11 13:50+00', '2025-12-11 16:10+00', '2025-12-15 10:30+00', NULL, NULL),
    (24, 'LUM-1024', 2,  1,    2, 'Bulk delete API times out over 10k rows', 'DELETE /records with more than 10,000 ids returns a gateway timeout.',         'resolved', 'high',   'email', '2025-12-15 10:07+00', '2025-12-15 11:40+00', '2025-12-19 15:45+00', NULL, 4),
    (25, 'LUM-1025', 7,  4,    1, 'Charged in USD instead of EUR',           'Our December invoice is in dollars; the contract specifies euros.',            'waiting_on_customer', 'high', 'email', '2025-12-16 09:26+00', '2025-12-16 10:15+00', NULL, NULL, NULL),
    (26, 'LUM-1026', 11, 6,    2, 'Two-factor codes rejected',               'Every TOTP code from my authenticator is rejected as invalid.',                'closed',   'urgent', 'phone', '2025-12-17 07:44+00', '2025-12-17 07:52+00', '2025-12-17 09:30+00', '2025-12-19 09:00+00', 1),
    (27, 'LUM-1027', 1,  2,    2, 'Printer-friendly view cuts off table',    'Printing the monthly summary chops the rightmost two columns.',                'waiting_on_customer', 'low', 'web', '2025-12-18 14:12+00', '2025-12-19 10:30+00', NULL, NULL, NULL),
    (28, 'LUM-1028', 9,  1,    2, 'Webhook signature validation fails',      'Signatures verify in staging but fail in production with the same secret.',    'waiting_on_customer', 'normal', 'email', '2025-12-22 10:53+00', '2025-12-22 13:40+00', NULL, NULL, NULL),
    (29, 'LUM-1029', 3,  5,    3, 'Rename workspace before launch',          'We rebranded and need the workspace slug changed everywhere.',                 'closed',   'low',    'chat',  '2025-12-23 09:17+00', '2025-12-23 09:40+00', '2025-12-23 11:00+00', '2025-12-27 09:00+00', 5),
    (30, 'LUM-1030', 10, 3,    1, 'December invoice missing line items',     'The PDF shows totals only; we need the per-seat breakdown restored.',          'waiting_on_customer', 'normal', 'email', '2026-01-02 10:41+00', '2026-01-02 14:20+00', NULL, NULL, NULL),
    (31, 'LUM-1031', 4,  2,    2, 'Data export stuck at 90 percent',         'The full-account export has shown 90% for two days.',                          'open',     'high',   'web',   '2026-01-05 08:36+00', '2026-01-05 09:25+00', NULL, NULL, NULL),
    (32, 'LUM-1032', 12, 4,    1, 'Add cost center to billing address',      'Finance wants our internal cost center code on every invoice.',                'waiting_on_customer', 'low', 'email', '2026-01-06 11:58+00', '2026-01-07 09:10+00', NULL, NULL, NULL),
    (33, 'LUM-1033', 8,  6,    2, 'Mobile notifications arrive twice',       'Every push notification shows up twice on iOS since the last update.',         'open',     'normal', 'web',   '2026-01-07 16:24+00', '2026-01-08 10:00+00', NULL, NULL, NULL),
    (34, 'LUM-1034', 5,  1,    2, 'Slack integration stopped posting',       'The #support channel has received nothing since January 3rd.',                 'open',     'high',   'chat',  '2026-01-08 09:09+00', '2026-01-08 09:31+00', NULL, NULL, NULL),
    (35, 'LUM-1035', 6,  5,    3, 'Walkthrough for new team members',        'Can someone run a 30-minute onboarding session for three new hires?',          'waiting_on_customer', 'low', 'web', '2026-01-09 13:37+00', '2026-01-09 15:45+00', NULL, NULL, NULL),
    (36, 'LUM-1036', 2,  NULL, 2, 'Latency spike on EU endpoints',           'p99 latency from Frankfurt tripled in the last hour; is there an incident?',   'open',     'urgent', 'email', '2026-01-12 07:51+00', NULL, NULL, NULL, NULL),
    (37, 'LUM-1037', 7,  2,    2, 'Audit log missing yesterday''s entries',  'The audit log jumps from Jan 10 straight to Jan 12.',                          'open',     'normal', 'email', '2026-01-12 11:19+00', '2026-01-12 14:05+00', NULL, NULL, NULL),
    (38, 'LUM-1038', 11, 3,    1, 'Update VAT rate for 2026',                'Norway''s VAT changed on Jan 1; our draft invoices still use the old rate.',   'waiting_on_customer', 'normal', 'email', '2026-01-13 10:28+00', '2026-01-13 11:55+00', NULL, NULL, NULL),
    (39, 'LUM-1039', 10, NULL, 1, 'Invoice PDF download returns 404',        'Clicking any invoice in billing history gives a not-found page.',              'open',     'high',   'web',   '2026-01-14 09:03+00', NULL, NULL, NULL, NULL),
    (40, 'LUM-1040', 1,  6,    2, 'Feature request: dark mode for reports',  'Shared report links blind recipients at night; a dark theme would help.',      'open',     'low',    'web',   '2026-01-14 15:46+00', '2026-01-14 16:30+00', NULL, NULL, NULL);

-- ── Ticket-tag links ───────────────────────────────────────────────
INSERT INTO lumina.ticket_tag (ticket_id, tag_id) VALUES
    (1, 5), (1, 9), (2, 17), (3, 3), (4, 7), (4, 8), (5, 2), (6, 6), (7, 1), (7, 14),
    (8, 11), (8, 17), (9, 4), (9, 2), (10, 9), (11, 3), (12, 5), (12, 19), (13, 17),
    (14, 12), (15, 2), (16, 9), (17, 5), (18, 11), (19, 18), (19, 2), (20, 16), (20, 15),
    (21, 2), (22, 1), (23, 17), (24, 5), (24, 9), (25, 2), (25, 3), (26, 14), (26, 1),
    (27, 20), (28, 6), (28, 14), (29, 17), (30, 3), (31, 12), (32, 3), (33, 7), (34, 13),
    (35, 17), (35, 11), (36, 9), (36, 15), (37, 14), (38, 3), (39, 3), (39, 8), (40, 10);

-- ── Comments: 3 per ticket, threaded opener -> reply -> follow-up ──
-- Comment ids are 3n-2, 3n-1, 3n for ticket n. Tickets 36 and 39 have had no
-- agent response, so all three comments are from the increasingly patient customer.
INSERT INTO lumina.ticket_comment (id, ticket_id, parent_comment_id, author_kind, author_id, body, created_at) OVERRIDING SYSTEM VALUE VALUES
    (1,   1,  NULL, 'customer', 2,  'The job ran fine for months; first 429 was Nov 3 at 02:04 UTC.',              '2025-11-03 08:14+00'),
    (2,   1,  1,    'agent',    1,  'A limit change on the batch endpoint rolled out Nov 2 — checking your tier.', '2025-11-03 09:02+00'),
    (3,   1,  2,    'customer', 2,  'Spacing requests 2s apart works. A heads-up next time would be appreciated.','2025-11-04 10:20+00'),
    (4,   2,  NULL, 'customer', 3,  'Step 5 of 5 stays gray even though the first four show green checks.',       '2025-11-04 10:22+00'),
    (5,   2,  4,    'agent',    5,  'Step 5 unlocks after email verification — your address shows unverified.',   '2025-11-04 16:45+00'),
    (6,   2,  5,    'customer', 3,  'Found the verification email in spam. Checklist complete now, thanks!',      '2025-11-05 09:30+00'),
    (7,   3,  NULL, 'customer', 1,  'Invoice INV-2025-1088 still shows IE-OLD-1234 as our VAT number.',           '2025-11-05 09:31+00'),
    (8,   3,  7,    'agent',    3,  'The VAT field on your billing profile had two entries; I removed the stale one.', '2025-11-05 11:15+00'),
    (9,   3,  8,    'customer', 1,  'Corrected invoice received — thank you for the fast turnaround.',            '2025-11-06 10:25+00'),
    (10,  4,  NULL, 'customer', 7,  'Crash happens on Pixel 8, app version 4.2.1, every single time.',            '2025-11-06 14:05+00'),
    (11,  4,  10,   'agent',    2,  'Reproduced on Android 15 — the crash is in the image resizer. Fix in 4.2.2.','2025-11-06 14:40+00'),
    (12,  4,  11,   'customer', 7,  '4.2.2 works. It took a few days but the fix is solid.',                      '2025-11-10 17:05+00'),
    (13,  5,  NULL, 'customer', 5,  'Charges of $499 on Nov 1 at 00:03 and 00:04. Card ends 7712.',               '2025-11-07 08:03+00'),
    (14,  5,  13,   'agent',    4,  'A payment-provider retry double-fired. Refunding the duplicate now.',        '2025-11-07 08:15+00'),
    (15,  5,  14,   'customer', 5,  'Refund visible. Frustrating that it happened, but resolved quickly.',        '2025-11-07 16:50+00'),
    (16,  6,  NULL, 'customer', 9,  'Delays started around Nov 6. Our SLA dashboards depend on these events.',    '2025-11-10 11:47+00'),
    (17,  6,  16,   'agent',    1,  'The webhook queue for your region was backed up; we have added workers.',    '2025-11-10 13:20+00'),
    (18,  6,  17,   'customer', 9,  'Latency back under 10 seconds since Thursday. Good to close.',               '2025-11-13 10:05+00'),
    (19,  7,  NULL, 'customer', 4,  'We rotated our IdP cert this morning; every SAML login now loops.',          '2025-11-12 07:58+00'),
    (20,  7,  19,   'agent',    6,  'Your SP config still pins the old cert fingerprint — updating it now.',      '2025-11-12 08:06+00'),
    (21,  7,  20,   'customer', 4,  'All 60 users can sign in again. Excellent response time.',                   '2025-11-12 12:35+00'),
    (22,  8,  NULL, 'customer', 8,  'Is there a way to import contacts without typing them one by one?',          '2025-11-13 15:12+00'),
    (23,  8,  22,   'agent',    5,  'Settings -> Data -> Import accepts CSV; template attached.',                 '2025-11-14 10:00+00'),
    (24,  8,  23,   'customer', 8,  'All 300 contacts in. The template made it painless.',                        '2025-11-14 10:35+00'),
    (25,  9,  NULL, 'customer', 10, 'Seat removal confirmed Oct 28 by email, but November billed all 10 seats.',  '2025-11-17 09:40+00'),
    (26,  9,  25,   'agent',    3,  'The removal was scheduled for the next cycle by mistake — issuing credit.',  '2025-11-17 10:25+00'),
    (27,  9,  26,   'customer', 10, 'Credit note received and applied. Thanks for sorting the proration.',        '2025-11-19 14:10+00'),
    (28,  10, NULL, 'customer', 6,  'We renamed from CascadeGear to Cascade Outdoors; search lost our history.',  '2025-11-18 13:26+00'),
    (29,  10, 28,   'agent',    2,  'The search index kept the old workspace key. Reindex is running.',           '2025-11-18 15:50+00'),
    (30,  10, 29,   'customer', 6,  'Old documents searchable again. Perfect.',                                   '2025-11-21 11:20+00'),
    (31,  11, NULL, 'customer', 12, 'AP requires PO-88231 on all invoices or they bounce back to us.',            '2025-11-19 10:15+00'),
    (32,  11, 31,   'agent',    4,  'Added a PO field to your billing profile; it prints under the address.',     '2025-11-19 14:30+00'),
    (33,  11, 32,   'customer', 12, 'November invoice shows the PO. Finance is satisfied.',                       '2025-11-20 09:50+00'),
    (34,  12, NULL, 'customer', 2,  'Docs page /api/limits says 100/min; the batch endpoint throttles at 60.',    '2025-11-20 16:08+00'),
    (35,  12, 34,   'agent',    1,  'Docs were stale — batch endpoints are 60/min. Page corrected today.',        '2025-11-21 09:30+00'),
    (36,  12, 35,   'customer', 2,  'Appreciated. Accurate docs beat generous limits.',                           '2025-11-24 10:05+00'),
    (37,  13, NULL, 'customer', 11, 'Migration ran long and the trial locked us out mid-import.',                 '2025-11-24 09:55+00'),
    (38,  13, 37,   'agent',    5,  'Extended your trial 14 days and unlocked the workspace.',                    '2025-11-24 10:12+00'),
    (39,  13, 38,   'customer', 11, 'Import finished. We will be subscribing this week.',                         '2025-11-24 13:05+00'),
    (40,  14, NULL, 'customer', 7,  'Any report over one page: page two is completely blank in the PDF.',         '2025-11-25 11:33+00'),
    (41,  14, 40,   'agent',    6,  'The page-break logic regressed in last week''s release; fix is queued.',     '2025-11-25 14:00+00'),
    (42,  14, 41,   'customer', 7,  'Confirmed fixed in today''s build.',                                         '2025-11-28 16:25+00'),
    (43,  15, NULL, 'customer', 1,  'New card, correct details, still 402 on every attempt.',                     '2025-11-26 08:47+00'),
    (44,  15, 43,   'agent',    3,  'Your bank was declining the $0 verification hold; retried with $1 and it saved.', '2025-11-26 09:10+00'),
    (45,  15, 44,   'customer', 1,  'Card saved and December charged correctly.',                                 '2025-11-26 15:35+00'),
    (46,  16, NULL, 'customer', 4,  '30-second loads Mondays 8-10am; the rest of the week is instant.',           '2025-12-01 09:12+00'),
    (47,  16, 46,   'agent',    2,  'Monday is when the weekly rollup rebuilds — we are moving it to Sunday night.', '2025-12-01 10:05+00'),
    (48,  16, 47,   'customer', 4,  'This Monday was fast. Whatever you moved, it worked.',                       '2025-12-05 17:05+00'),
    (49,  17, NULL, 'customer', 9,  'CI needs keys that cannot touch production data.',                           '2025-12-02 14:29+00'),
    (50,  17, 49,   'agent',    1,  'Staging keys issued — prefix sk_stage_. They hit an isolated environment.',  '2025-12-03 09:15+00'),
    (51,  17, 50,   'customer', 9,  'Pipeline green. Thanks.',                                                    '2025-12-03 11:45+00'),
    (52,  18, NULL, 'customer', 3,  'I keep hunting for the shortcuts overlay I saw once.',                       '2025-12-03 10:18+00'),
    (53,  18, 52,   'agent',    5,  'Press ? anywhere — the overlay lists every shortcut.',                       '2025-12-03 10:26+00'),
    (54,  18, 53,   'customer', 3,  'So simple. Thank you!',                                                      '2025-12-03 10:50+00'),
    (55,  19, NULL, 'customer', 10, 'Calculator showed $840 for the upgrade; we were charged $1,120.',            '2025-12-04 15:44+00'),
    (56,  19, 55,   'agent',    4,  'The calculator ignored your two add-on seats. Charge is correct; calculator is being fixed.', '2025-12-05 09:20+00'),
    (57,  19, 56,   'customer', 10, 'Understood, though the calculator cost us a budget meeting.',                '2025-12-08 14:20+00'),
    (58,  20, NULL, 'customer', 12, 'Outlook quarantines every notification from our workspace since Friday.',    '2025-12-08 08:21+00'),
    (59,  20, 58,   'agent',    6,  'A shared sending IP was blacklisted. We moved you to a dedicated IP and re-warmed DKIM.', '2025-12-08 08:50+00'),
    (60,  20, 59,   'customer', 12, 'Deliverability restored across all recipients we tested.',                   '2025-12-12 16:05+00'),
    (61,  21, NULL, 'customer', 5,  'Need the quote on letterhead with our legal entity name, please.',           '2025-12-09 11:02+00'),
    (62,  21, 61,   'agent',    3,  'Formal quote Q-2025-441 sent for 40 seats, annual, net-30.',                 '2025-12-09 15:30+00'),
    (63,  21, 62,   'customer', 5,  'Signed and returned. Looking forward to the upgrade.',                       '2025-12-10 10:05+00'),
    (64,  22, NULL, 'customer', 8,  'Reset link says expired even when I click it within seconds.',               '2025-12-10 09:38+00'),
    (65,  22, 64,   'agent',    2,  'Your mail gateway pre-fetches links, consuming the one-time token. Reset links are now click-tolerant.', '2025-12-10 09:55+00'),
    (66,  22, 65,   'customer', 8,  'Reset worked this time. Interesting root cause!',                            '2025-12-11 12:25+00'),
    (67,  23, NULL, 'customer', 6,  'New hire clicks the invite and lands on a 404.',                             '2025-12-11 13:50+00'),
    (68,  23, 67,   'agent',    5,  'The invite predates your workspace rename — reissued against the new slug.', '2025-12-11 16:10+00'),
    (69,  23, 68,   'customer', 6,  'She is in. Thanks for the quick reissue.',                                   '2025-12-15 10:35+00'),
    (70,  24, NULL, 'customer', 2,  'Deletes of 10k+ ids time out at exactly 30 seconds.',                        '2025-12-15 10:07+00'),
    (71,  24, 70,   'agent',    1,  'The endpoint now accepts batches and processes them asynchronously — new docs linked.', '2025-12-15 11:40+00'),
    (72,  24, 71,   'customer', 2,  'Async batches finished 200k deletes overnight. Much better.',                '2025-12-19 15:50+00'),
    (73,  25, NULL, 'customer', 7,  'Contract clause 4.2 fixes billing in EUR; invoice INV-2025-1201 is USD.',    '2025-12-16 09:26+00'),
    (74,  25, 73,   'agent',    4,  'Agreed — I need a signed copy of the currency addendum to switch it. Can you attach it?', '2025-12-16 10:15+00'),
    (75,  25, 74,   'customer', 7,  'Chasing our legal team for the addendum; will attach when signed.',          '2025-12-18 11:30+00'),
    (76,  26, NULL, 'customer', 11, 'Every code from my authenticator app is rejected.',                          '2025-12-17 07:44+00'),
    (77,  26, 76,   'agent',    6,  'Your phone clock is 90 seconds ahead — TOTP tolerates 30. Re-sync device time and retry.', '2025-12-17 07:52+00'),
    (78,  26, 77,   'customer', 11, 'That fixed it, but losing account access for an hour was scary.',            '2025-12-17 09:35+00'),
    (79,  27, NULL, 'customer', 1,  'Print preview drops the two rightmost columns of the summary table.',        '2025-12-18 14:12+00'),
    (80,  27, 79,   'agent',    2,  'Does it happen in landscape too, or only portrait? A test print would help us narrow it.', '2025-12-19 10:30+00'),
    (81,  27, 80,   'customer', 1,  'Will test landscape after the holidays and report back.',                    '2025-12-22 09:15+00'),
    (82,  28, NULL, 'customer', 9,  'Same secret verifies in staging, fails in prod. Code identical.',            '2025-12-22 10:53+00'),
    (83,  28, 82,   'agent',    1,  'Prod signs with the NEW secret after your rotation — is your prod config reading the old env var?', '2025-12-22 13:40+00'),
    (84,  28, 83,   'customer', 9,  'Checking with our platform team which secret prod actually loads.',          '2025-12-23 09:40+00'),
    (85,  29, NULL, 'customer', 3,  'We are Bluebird Patisserie now — the old slug is on every shared link.',     '2025-12-23 09:17+00'),
    (86,  29, 85,   'agent',    5,  'Slug renamed with permanent redirects from the old links.',                  '2025-12-23 09:40+00'),
    (87,  29, 86,   'customer', 3,  'Redirects work. Launch saved.',                                              '2025-12-23 11:05+00'),
    (88,  30, NULL, 'customer', 10, 'December PDF shows one line: "Subscription — $4,200". We need per-seat rows.','2026-01-02 10:41+00'),
    (89,  30, 88,   'agent',    3,  'A template change collapsed line items. Which format do you need — per-seat or per-team?', '2026-01-02 14:20+00'),
    (90,  30, 89,   'customer', 10, 'Per-seat, matching the November layout. Confirming with finance first.',     '2026-01-05 09:20+00'),
    (91,  31, NULL, 'customer', 4,  'Export id EXP-99120 has displayed 90% since Saturday.',                      '2026-01-05 08:36+00'),
    (92,  31, 91,   'agent',    2,  'The export worker crashed on a corrupted attachment — we are skipping it and resuming.', '2026-01-05 09:25+00'),
    (93,  31, 92,   'customer', 4,  'Still at 90% this morning. What is the ETA?',                                '2026-01-07 08:30+00'),
    (94,  32, NULL, 'customer', 12, 'Cost center CC-7741 must appear near the billing address block.',            '2026-01-06 11:58+00'),
    (95,  32, 94,   'agent',    4,  'We can add a free-text line under the address. Is "Cost Center: CC-7741" acceptable to finance?', '2026-01-07 09:10+00'),
    (96,  32, 95,   'customer', 12, 'Asking finance whether the wording passes their audit rules.',               '2026-01-08 10:45+00'),
    (97,  33, NULL, 'customer', 8,  'Every push arrives twice on iOS 18.2 since app version 4.3.0.',              '2026-01-07 16:24+00'),
    (98,  33, 97,   'agent',    6,  'We see duplicate device tokens for your account — investigating the registration flow.', '2026-01-08 10:00+00'),
    (99,  33, 98,   'customer', 8,  'Also happening on my colleague''s iPhone 15, same version.',                 '2026-01-09 11:20+00'),
    (100, 34, NULL, 'customer', 5,  'Nothing has posted to #support since Jan 3, though the integration shows connected.', '2026-01-08 09:09+00'),
    (101, 34, 100,  'agent',    1,  'Slack revoked the token during their Jan 3 security sweep — reauthorization link sent.', '2026-01-08 09:31+00'),
    (102, 34, 101,  'customer', 5,  'Our workspace admin is on leave; reauthorizing when she returns Monday.',    '2026-01-09 14:10+00'),
    (103, 35, NULL, 'customer', 6,  'Three new hires start Jan 19 — could we book a walkthrough that week?',      '2026-01-09 13:37+00'),
    (104, 35, 103,  'agent',    5,  'Happy to. I sent three slots for the week of the 19th — pick whichever suits.', '2026-01-09 15:45+00'),
    (105, 35, 104,  'customer', 6,  'Checking calendars; will confirm a slot shortly.',                           '2026-01-12 10:30+00'),
    (106, 36, NULL, 'customer', 2,  'Frankfurt p99 went from 180ms to 600ms within an hour. Incident?',           '2026-01-12 07:51+00'),
    (107, 36, 106,  'customer', 2,  'Now seeing intermittent 502s as well. This is affecting production.',        '2026-01-12 09:40+00'),
    (108, 36, 107,  'customer', 2,  'Second business day with no response on an urgent ticket. Please escalate.', '2026-01-13 08:15+00'),
    (109, 37, NULL, 'customer', 7,  'Audit log has zero entries for Jan 11 — compliance needs them.',             '2026-01-12 11:19+00'),
    (110, 37, 109,  'agent',    2,  'Entries exist in cold storage; the UI query skips one shard. Restoring visibility.', '2026-01-12 14:05+00'),
    (111, 37, 110,  'customer', 7,  'We need them before the auditor session on Jan 20 — timeline?',              '2026-01-14 09:50+00'),
    (112, 38, NULL, 'customer', 11, 'Norwegian VAT is 26% as of Jan 1; drafts still compute 25%.',                '2026-01-13 10:28+00'),
    (113, 38, 112,  'agent',    3,  'Rate table updated for 2026. Can you confirm your org number so I re-issue the drafts?', '2026-01-13 11:55+00'),
    (114, 38, 113,  'customer', 11, 'Org number is 987 654 321. Send the corrected drafts when ready.',           '2026-01-14 08:40+00'),
    (115, 39, NULL, 'customer', 10, 'Every invoice link under Billing -> History returns a 404.',                 '2026-01-14 09:03+00'),
    (116, 39, 115,  'customer', 10, 'Tried two browsers and a colleague''s account — same 404.',                  '2026-01-14 13:20+00'),
    (117, 39, 116,  'customer', 10, 'We need November''s invoice for a tax filing tomorrow. Urgent.',              '2026-01-14 17:45+00'),
    (118, 40, NULL, 'customer', 1,  'Recipients open shared reports at night; a dark theme would be kind.',       '2026-01-14 15:46+00'),
    (119, 40, 118,  'agent',    6,  'Logged as a feature request — it is one of our most-asked. No date promised yet.', '2026-01-14 16:30+00'),
    (120, 40, 119,  'customer', 1,  'Understood. Add my vote and keep me posted.',                                '2026-01-14 17:10+00');

-- ── Events: derived deterministically from the tickets ─────────────
-- One 'created' event per ticket, an 'assigned' event where an agent is set,
-- and a 'status_changed' event at each recorded transition. Rows remain
-- nameable ("the created event of LUM-1036").
INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'created', jsonb_build_object('channel', channel, 'priority', priority), created_at
FROM lumina.ticket;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'assigned', jsonb_build_object('agent_id', assigned_agent_id), created_at + interval '20 minutes'
FROM lumina.ticket
WHERE assigned_agent_id IS NOT NULL;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'status_changed', jsonb_build_object('from', 'open', 'to', 'resolved'), resolved_at
FROM lumina.ticket
WHERE resolved_at IS NOT NULL;

INSERT INTO lumina.ticket_event (ticket_id, event_kind, payload, occurred_at)
SELECT id, 'status_changed', jsonb_build_object('from', 'resolved', 'to', 'closed'), closed_at
FROM lumina.ticket
WHERE closed_at IS NOT NULL;

-- ── Attachments ────────────────────────────────────────────────────
INSERT INTO lumina.attachment (id, ticket_id, comment_id, filename, content_kind, byte_size, uploaded_at) OVERRIDING SYSTEM VALUE VALUES
    (1, 4,  10,  'crash-screenshot.png',    'image/png',       482113,  '2025-11-06 14:05+00'),
    (2, 5,  13,  'statement-november.pdf',  'application/pdf', 128944,  '2025-11-07 08:03+00'),
    (3, 14, 40,  'blank-page-report.pdf',   'application/pdf', 291502,  '2025-11-25 11:33+00'),
    (4, 25, 73,  'contract-clause-4-2.pdf', 'application/pdf', 88211,   '2025-12-16 09:26+00'),
    (5, 31, 91,  'export-progress.png',     'image/png',       102775,  '2026-01-05 08:36+00'),
    (6, 36, 106, 'latency-graph.png',       'image/png',       244903,  '2026-01-12 07:51+00');

-- ── SLA policies ───────────────────────────────────────────────────
INSERT INTO lumina.sla_policy (id, name, applies_to_priority, first_response_minutes, resolution_minutes) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Urgent — all hands',   'urgent', 30,  240),
    (2, 'High — same day',      'high',   60,  480),
    (3, 'Normal — next day',    'normal', 240, 1440),
    (4, 'Low — best effort',    'low',    480, 2880);

-- ── Re-sync identity sequences so reader INSERTs get clean ids ─────
SELECT setval(pg_get_serial_sequence('lumina.team', 'id'),           (SELECT max(id) FROM lumina.team));
SELECT setval(pg_get_serial_sequence('lumina.agent', 'id'),          (SELECT max(id) FROM lumina.agent));
SELECT setval(pg_get_serial_sequence('lumina.customer', 'id'),       (SELECT max(id) FROM lumina.customer));
SELECT setval(pg_get_serial_sequence('lumina.ticket', 'id'),         (SELECT max(id) FROM lumina.ticket));
SELECT setval(pg_get_serial_sequence('lumina.ticket_comment', 'id'), (SELECT max(id) FROM lumina.ticket_comment));
SELECT setval(pg_get_serial_sequence('lumina.tag', 'id'),            (SELECT max(id) FROM lumina.tag));
SELECT setval(pg_get_serial_sequence('lumina.attachment', 'id'),     (SELECT max(id) FROM lumina.attachment));
SELECT setval(pg_get_serial_sequence('lumina.sla_policy', 'id'),     (SELECT max(id) FROM lumina.sla_policy));
