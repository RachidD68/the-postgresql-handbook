-- Listing 4.3 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch04/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 4
-- As spoken: urgent, or high and open... but AND binds tighter than OR.
SELECT count(*) AS matches
FROM ticket
WHERE priority = 'urgent' OR priority = 'high' AND status = 'open';

-- As intended:
SELECT count(*) AS matches
FROM ticket
WHERE (priority = 'urgent' OR priority = 'high') AND status = 'open';
