-- Migration 030 (Chapter 6) — the armor.
--
-- Every foreign key with its deliberately chosen ON DELETE action, the CHECK
-- battery, the polymorphic-author guard, one partial unique index, and the
-- generated resolution_minutes column. Matches Chapter 6's DDL listings
-- statement-for-statement (bare names per Appendix C rule 11).
--
-- ON DELETE choices, reasoned in the chapter:
--   RESTRICT  where deleting the parent would erase history someone will ask
--             for (customers, teams, tags never silently vanish).
--   CASCADE   where children are meaningless without the parent (a ticket's
--             comments, events, tag links, attachments die with it).
--   SET NULL  where the child outlives the relationship (an agent leaves;
--             their tickets return to the queue, their protege loses a manager).

-- ── Foreign keys ───────────────────────────────────────────────────
ALTER TABLE agent
    ADD CONSTRAINT agent_team_fk
        FOREIGN KEY (team_id) REFERENCES team (id) ON DELETE RESTRICT,
    ADD CONSTRAINT agent_manager_fk
        FOREIGN KEY (manager_id) REFERENCES agent (id) ON DELETE SET NULL;

ALTER TABLE ticket
    ADD CONSTRAINT ticket_customer_fk
        FOREIGN KEY (customer_id) REFERENCES customer (id) ON DELETE RESTRICT,
    ADD CONSTRAINT ticket_agent_fk
        FOREIGN KEY (assigned_agent_id) REFERENCES agent (id) ON DELETE SET NULL,
    ADD CONSTRAINT ticket_team_fk
        FOREIGN KEY (team_id) REFERENCES team (id) ON DELETE RESTRICT;

ALTER TABLE ticket_comment
    ADD CONSTRAINT comment_ticket_fk
        FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE,
    ADD CONSTRAINT comment_parent_fk
        FOREIGN KEY (parent_comment_id) REFERENCES ticket_comment (id) ON DELETE CASCADE;

ALTER TABLE ticket_tag
    ADD CONSTRAINT ticket_tag_ticket_fk
        FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE,
    ADD CONSTRAINT ticket_tag_tag_fk
        FOREIGN KEY (tag_id) REFERENCES tag (id) ON DELETE RESTRICT;

ALTER TABLE ticket_event
    ADD CONSTRAINT event_ticket_fk
        FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE;

ALTER TABLE attachment
    ADD CONSTRAINT attachment_ticket_fk
        FOREIGN KEY (ticket_id) REFERENCES ticket (id) ON DELETE CASCADE,
    ADD CONSTRAINT attachment_comment_fk
        FOREIGN KEY (comment_id) REFERENCES ticket_comment (id) ON DELETE SET NULL;

-- ── CHECK constraints ──────────────────────────────────────────────
ALTER TABLE ticket
    ADD CONSTRAINT ticket_status_check
        CHECK (status IN ('open', 'waiting_on_customer', 'resolved', 'closed')),
    ADD CONSTRAINT ticket_satisfaction_check
        CHECK (satisfaction BETWEEN 1 AND 5),
    ADD CONSTRAINT ticket_resolution_order_check
        CHECK (resolved_at >= created_at);

-- The polymorphic author pattern cannot be foreign-keyed; a CHECK at least
-- keeps the discriminator honest.
ALTER TABLE ticket_comment
    ADD CONSTRAINT comment_author_kind_check
        CHECK (author_kind IN ('agent', 'customer'));

-- Chapter 5's promise kept: a length rule as a named, alterable CHECK instead
-- of a varchar(n) guess. The chapter adds this one NOT VALID and then VALIDATEs
-- it (the live-table pattern); this file records the settled result.
ALTER TABLE ticket
    ADD CONSTRAINT ticket_subject_length_check
        CHECK (length(subject) <= 120);

-- ── One partial unique index ───────────────────────────────────────
-- A customer cannot file the same subject twice while the first is still open.
CREATE UNIQUE INDEX ticket_open_duplicate_guard
    ON ticket (customer_id, subject)
    WHERE status = 'open';

-- ── Generated column ───────────────────────────────────────────────
ALTER TABLE ticket
    ADD COLUMN resolution_minutes integer
        GENERATED ALWAYS AS
            ((EXTRACT(EPOCH FROM (resolved_at - created_at)) / 60)::integer)
        STORED;
