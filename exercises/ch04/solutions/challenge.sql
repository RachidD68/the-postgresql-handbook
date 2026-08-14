-- Solution to Exercise 4.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 4

-- "Answered later than N minutes" is an interval comparison — but on a
-- never-answered ticket first_response_at is NULL, the subtraction is NULL,
-- and the > is UNKNOWN, so those rows need their own IS NULL disjunct.
SELECT reference, priority,
       first_response_at - created_at AS waited
FROM ticket
WHERE (priority = 'urgent'
       AND (first_response_at - created_at > interval '30 minutes'
            OR first_response_at IS NULL))
   OR (priority = 'high'
       AND (first_response_at - created_at > interval '60 minutes'
            OR first_response_at IS NULL))
ORDER BY waited DESC NULLS FIRST;

-- Three breaches: LUM-1036 (urgent, never answered) and LUM-1039 (high,
-- never answered) sort to the top as the fires still burning; LUM-1024
-- (high) was answered in 1:33 against a 60-minute promise.
