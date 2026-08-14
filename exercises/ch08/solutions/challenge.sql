-- Solution to Exercise 8.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 8

-- The audit: the join's grain is one row per (ticket, tag) pair, so
-- count(*) counts tag-links, count(DISTINCT t.id) counts tickets, and
-- their ratio IS tags-per-ticket. The idea is right; the arithmetic lies:
SELECT tm.name AS team,
       count(*) / count(DISTINCT t.id) AS avg_tags
FROM ticket AS t
JOIN ticket_tag AS tt ON tt.ticket_id = t.id
JOIN team AS tm ON tm.id = t.team_id
GROUP BY tm.name
ORDER BY tm.name;
-- Every team prints 1 — bigint / bigint truncates, and 1.33 becomes 1.

-- The fix is one cast:
SELECT tm.name AS team,
       round(count(*)::numeric / count(DISTINCT t.id), 2) AS avg_tags
FROM ticket AS t
JOIN ticket_tag AS tt ON tt.ticket_id = t.id
JOIN team AS tm ON tm.id = t.team_id
GROUP BY tm.name
ORDER BY tm.name;

--  Billing 1.33, Onboarding 1.29, Technical Support 1.43 — the true
--  ratios. Verdict: right number, wrong type.
