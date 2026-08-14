-- Solution to Exercise 16.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 16

-- Page 1 (both paginations agree here):
WITH lb AS (
    SELECT a.full_name, count(t.resolution_minutes) AS resolved
    FROM agent AS a
    LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
    GROUP BY a.full_name
)
SELECT full_name, resolved
FROM lb
ORDER BY resolved DESC, full_name DESC
LIMIT 10;
-- Ends at (3080, 'Agent 13') — the keyset anchor.

-- Page 2, keyset: row-comparison against the last row actually served.
-- Works because both sort keys run the same direction (DESC, DESC).
WITH lb AS (
    SELECT a.full_name, count(t.resolution_minutes) AS resolved
    FROM agent AS a
    LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
    GROUP BY a.full_name
)
SELECT full_name, resolved
FROM lb
WHERE (resolved, full_name) < (3080, 'Agent 13')
ORDER BY resolved DESC, full_name DESC
LIMIT 10;
-- Starts at Agent 08 (3080).

-- Now shift the ground under both, without keeping the change:
BEGIN;

INSERT INTO ticket (reference, customer_id, assigned_agent_id, team_id,
                    subject, body, status, priority, channel,
                    created_at, first_response_at, resolved_at)
SELECT 'LUM-99999', 1, a.id, a.team_id,
       'Keyset pagination demo', 'Inserted inside a rolled-back transaction.',
       'resolved', 'normal', 'web',
       '2026-01-15 09:00:00+00', '2026-01-15 09:05:00+00',
       '2026-01-15 09:30:00+00'
FROM agent AS a
WHERE a.full_name = 'Agent 08';
-- Agent 08: 3080 -> 3081 resolved, jumping from page 2 into page 1.

-- Page 2 again, keyset (same anchor): begins at Agent 01 — no duplicate,
-- no gap. Agent 08 left the page upward; everyone the reader has not yet
-- seen is still exactly once in the pages that follow.
WITH lb AS (
    SELECT a.full_name, count(t.resolution_minutes) AS resolved
    FROM agent AS a
    LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
    GROUP BY a.full_name
)
SELECT full_name, resolved
FROM lb
WHERE (resolved, full_name) < (3080, 'Agent 13')
ORDER BY resolved DESC, full_name DESC
LIMIT 10;

-- Page 2 again, OFFSET: begins with Agent 13 — a DUPLICATE. The reader saw
-- Agent 13 close page 1; OFFSET re-counts ten from the new top, and the
-- row that slid from rank 10 to 11 is served twice.
WITH lb AS (
    SELECT a.full_name, count(t.resolution_minutes) AS resolved
    FROM agent AS a
    LEFT JOIN ticket AS t ON t.assigned_agent_id = a.id
    GROUP BY a.full_name
)
SELECT full_name, resolved
FROM lb
ORDER BY resolved DESC, full_name DESC
OFFSET 10 LIMIT 10;

ROLLBACK;

-- Keyset's page was the honest one because it anchors to the last row the
-- reader actually saw; OFFSET anchors to a row COUNT from the top, and the
-- top just changed. (Mixed ASC/DESC sorts need the expanded OR form — row
-- comparison requires all keys to point the same way.)
