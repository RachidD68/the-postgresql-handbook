-- Listing 17.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
ALTER TABLE ticket ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket FORCE ROW LEVEL SECURITY;

CREATE POLICY customer_isolation ON ticket
    TO lumina_app
    USING (customer_id = current_setting('app.customer_id', true)::bigint)
    WITH CHECK (customer_id = current_setting('app.customer_id', true)::bigint);

CREATE POLICY staff_full_access ON ticket
    TO support_agent
    USING (true);
