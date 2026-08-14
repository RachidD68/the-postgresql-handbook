-- Solution to Exercise 17.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 17,
--              then the chapter's own role/grant/RLS listings
--              (mirrored by schema/migrations/090-ch17-security.sql).

-- One ALTER POLICY, in place — no drop, no recreate:
ALTER POLICY staff_full_access ON ticket
    USING (team_id = current_setting('app.team_id', true)::bigint);

-- Verify with two team ids (support_agent has column grants on ticket):
SET ROLE support_agent;
SET app.team_id = '1';
SELECT count(id) FROM ticket;   -- 24,012
SET app.team_id = '2';
SELECT count(id) FROM ticket;   -- 40,021
RESET ROLE;

-- What ALTER POLICY cannot change: the policy's command (FOR SELECT,
-- FOR ALL, ...) and its PERMISSIVE/RESTRICTIVE kind. Changing either is
-- the case that still requires DROP POLICY and CREATE POLICY.
