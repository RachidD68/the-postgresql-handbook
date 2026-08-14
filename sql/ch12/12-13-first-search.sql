-- Listing 12.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT reference, subject
FROM ticket
WHERE to_tsvector('english', subject || ' ' || body)
      @@ websearch_to_tsquery('english', 'crashed')
ORDER BY reference;
