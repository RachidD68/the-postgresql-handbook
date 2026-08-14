-- Listing 11.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
ALTER TABLE ticket
    ADD COLUMN custom_fields jsonb NOT NULL DEFAULT '{}';

UPDATE ticket AS t
SET custom_fields = jsonb_build_object(
        'cost_center', 'CC-' || lpad((t.customer_id * 7)::text, 4, '0'),
        'po_number',   'PO-2026-' || lpad(t.id::text, 3, '0'))
FROM customer AS c
WHERE c.id = t.customer_id
  AND c.plan = 'enterprise';
