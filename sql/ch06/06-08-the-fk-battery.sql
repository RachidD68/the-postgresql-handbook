-- Listing 6.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
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
