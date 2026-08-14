-- 040-ch11-jsonb.sql — Chapter 11's work product, applied from Chapter 12 onward.
-- Mirrors listings 11-08 and 11-10 (the book's listings ARE the source; this file
-- replays them so State(N >= 12) matches a reader who followed Ch11).
--
-- APPLIED TWICE by the reset scripts, deliberately. Migrations run before seeds
-- (they shape the schema the seeds load into), so on the first pass the backfill
-- UPDATEs meet an empty ticket table and do nothing. The reset therefore re-runs
-- this file AFTER the seeds, where the same UPDATEs land on real rows — that is
-- what makes the harness state match a reader who ran Ch11's listings on seeded
-- data. Hence IF NOT EXISTS on the DDL (a logged deviation from listing 11-08's
-- plain ADD COLUMN) and backfill statements that are safe to repeat: the
-- cost_center/po_number SET is absolute, and || with an identical object is
-- idempotent. Gap found at the B5 gate; before it, custom_fields was '{}' in
-- every harness row from State(12) onward.

ALTER TABLE lumina.ticket
    ADD COLUMN IF NOT EXISTS custom_fields jsonb NOT NULL DEFAULT '{}';

-- Enterprise customers file with procurement metadata. Deterministic values:
-- cost_center derives from customer id, po_number from ticket id.
UPDATE lumina.ticket AS t
SET custom_fields = jsonb_build_object(
        'cost_center', 'CC-' || lpad((t.customer_id * 7)::text, 4, '0'),
        'po_number',   'PO-2026-' || lpad(t.id::text, 3, '0'))
FROM lumina.customer AS c
WHERE c.id = t.customer_id
  AND c.plan = 'enterprise';

-- The two mobile-tagged tickets carry nested device info (deep paths need depth).
UPDATE lumina.ticket
SET custom_fields = custom_fields
        || '{"device": {"os": "iOS", "os_version": "19.2", "app_version": "4.8.1"}}'
WHERE reference = 'LUM-1004';

UPDATE lumina.ticket
SET custom_fields = custom_fields
        || '{"device": {"os": "Android", "os_version": "17", "app_version": "4.7.0"}}'
WHERE reference = 'LUM-1033';
