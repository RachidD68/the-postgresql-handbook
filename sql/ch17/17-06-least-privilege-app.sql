-- Listing 17.6 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
GRANT SELECT, INSERT, UPDATE
    ON ticket, ticket_comment, ticket_event
    TO lumina_app;

GRANT SELECT
    ON customer, agent, team, tag, ticket_tag, sla_policy, ticket_job
    TO lumina_app;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA lumina TO lumina_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA lumina
    GRANT SELECT, INSERT, UPDATE ON TABLES TO lumina_app;
