-- The PostgreSQL Handbook — the Lumina Helpdesk core schema (Chapter 2)
--
-- STATUS: FROZEN (author-approved 2026-08-10, at the close of Chapter 2).
-- Every later shape change is an additive, numbered migration in
-- schema/migrations/. Editing this file now means re-rendering Ch2 onward
-- and re-verifying every chapter — do not touch it without that intent.
--
-- Deliberate Chapter-2-level design: primary keys, NOT NULL, and the two UNIQUE
-- constraints the domain cannot live without. Foreign keys, CHECK constraints,
-- and generated columns arrive in Chapter 6 (030-ch06-constraints.sql) as ALTER
-- TABLE statements on an already-populated database — the truer lesson.
--
-- Reserved-word contract (enforced by Book/_shared/__tests__/sqlLex.test.js):
-- no column here may be named type, role, text, date, or money.

CREATE SCHEMA lumina;

-- Support teams: Billing, Technical Support, Onboarding.
CREATE TABLE lumina.team (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL,
    focus_area  text NOT NULL,
    created_at  timestamptz NOT NULL
);

-- Support agents. manager_id is a self-reference (the Chapter 7 self-join);
-- it becomes a real foreign key in Chapter 6.
CREATE TABLE lumina.agent (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id     bigint NOT NULL,
    manager_id  bigint,
    full_name   text NOT NULL,
    email       citext NOT NULL UNIQUE,
    hired_on    date NOT NULL
);

-- The customers who open tickets. plan is free / pro / enterprise.
CREATE TABLE lumina.customer (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name  text NOT NULL,
    full_name     text NOT NULL,
    email         citext NOT NULL UNIQUE,
    plan          text NOT NULL,
    signed_up_at  timestamptz NOT NULL
);

-- The heart of the domain. Nullable timestamps are deliberate: they drive the
-- three-valued-logic lessons in Chapter 4 and the SLA math in Chapter 8.
CREATE TABLE lumina.ticket (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference          text NOT NULL UNIQUE,
    customer_id        bigint NOT NULL,
    assigned_agent_id  bigint,
    team_id            bigint NOT NULL,
    subject            text NOT NULL,
    body               text NOT NULL,
    status             text NOT NULL,
    priority           text NOT NULL,
    channel            text NOT NULL,
    created_at         timestamptz NOT NULL,
    first_response_at  timestamptz,
    resolved_at        timestamptz,
    closed_at          timestamptz,
    satisfaction       smallint
);

-- Threaded conversation on a ticket. parent_comment_id builds the reply chains
-- that Chapter 9's recursive CTEs walk. author_kind is 'agent' or 'customer';
-- author_id points into the matching table.
CREATE TABLE lumina.ticket_comment (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id          bigint NOT NULL,
    parent_comment_id  bigint,
    author_kind        text NOT NULL,
    author_id          bigint NOT NULL,
    body               text NOT NULL,
    created_at         timestamptz NOT NULL
);

CREATE TABLE lumina.tag (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         text NOT NULL UNIQUE,
    description  text NOT NULL
);

-- Pure join table; the composite primary key is the whole point of it.
CREATE TABLE lumina.ticket_tag (
    ticket_id  bigint NOT NULL,
    tag_id     bigint NOT NULL,
    PRIMARY KEY (ticket_id, tag_id)
);

-- Append-only audit trail. payload is JSONB from day one (events are naturally
-- semi-structured); Chapter 11 teaches the operators, Chapter 19 partitions it.
CREATE TABLE lumina.ticket_event (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id    bigint NOT NULL,
    event_kind   text NOT NULL,
    payload      jsonb NOT NULL DEFAULT '{}',
    occurred_at  timestamptz NOT NULL
);

-- File attachments, on the ticket or on a specific comment.
CREATE TABLE lumina.attachment (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     bigint NOT NULL,
    comment_id    bigint,
    filename      text NOT NULL,
    content_kind  text NOT NULL,
    byte_size     bigint NOT NULL,
    uploaded_at   timestamptz NOT NULL
);

-- Response-time promises per priority; the raw material for Chapter 8's
-- SLA-breach dashboard.
CREATE TABLE lumina.sla_policy (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                    text NOT NULL,
    applies_to_priority     text NOT NULL UNIQUE,
    first_response_minutes  integer NOT NULL,
    resolution_minutes      integer NOT NULL
);
