-- Listing 15.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch15/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 15
CREATE INDEX ticket_assigned_agent_idx ON ticket (assigned_agent_id);
CREATE INDEX ticket_team_idx           ON ticket (team_id);
CREATE INDEX comment_ticket_idx        ON ticket_comment (ticket_id);
CREATE INDEX event_ticket_idx          ON ticket_event (ticket_id);
