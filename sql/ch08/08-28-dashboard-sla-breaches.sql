-- Listing 8.28 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch08/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 8
SELECT t.priority,
       s.first_response_minutes AS promised,
       count(*) AS tickets,
       count(*) FILTER
           (WHERE t.first_response_at - t.created_at >
                  s.first_response_minutes * interval '1 minute') AS breached,
       count(*) FILTER (WHERE t.first_response_at IS NULL) AS never_answered
FROM ticket AS t
JOIN sla_policy AS s ON s.applies_to_priority = t.priority::text
GROUP BY t.priority, s.first_response_minutes
ORDER BY t.priority DESC;
