-- Listing 11.15 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
SELECT reference,
       custom_fields ? 'po_number'                    AS has_po,
       custom_fields ?| array['device', 'po_number']  AS has_either,
       custom_fields ?& array['device', 'po_number']  AS has_both
FROM ticket
WHERE id IN (1, 2, 4)
ORDER BY reference;
