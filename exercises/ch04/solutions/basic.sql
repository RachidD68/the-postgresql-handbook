-- Solution to Exercise 4.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 4

-- Urgent-first, newest-first within each priority:
SELECT reference, priority, subject
FROM ticket
WHERE status = 'open'
ORDER BY CASE priority
             WHEN 'urgent' THEN 1
             WHEN 'high'   THEN 2
             WHEN 'normal' THEN 3
             ELSE 4
         END,
         created_at DESC;
-- Seven rows, LUM-1036 (urgent) on top.

-- The flip: only the second sort key changes — created_at (ASC).
SELECT reference, priority, subject
FROM ticket
WHERE status = 'open'
ORDER BY CASE priority
             WHEN 'urgent' THEN 1
             WHEN 'high'   THEN 2
             WHEN 'normal' THEN 3
             ELSE 4
         END,
         created_at;

-- Verdict: oldest-first. Within a priority, the ticket that has waited
-- longest should be served next — newest-first starves old tickets forever.
