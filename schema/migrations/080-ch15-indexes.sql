-- 080-ch15-indexes.sql — Chapter 15's work product, applied from Chapter 16 onward.
-- Mirrors the chapter's CREATE INDEX listings (the book's listings ARE the source;
-- this file replays them so State(N >= 16) matches a reader who followed Ch15).
-- Deliberately ABSENT: ticket_assigned_agent_idx — created mid-chapter, then
-- dropped in the hygiene section as redundant with ticket_workload_idx's leftmost
-- column. Also absent: the demo-only indexes created and dropped in-chapter
-- (event_occurred_btree_demo from the BRIN size comparison, and the s1..s6
-- write-amplification scratch set on ticket_scratch).

-- FK indexes (the classic gap: PostgreSQL does not index FK columns for you).
CREATE INDEX ticket_customer_idx       ON lumina.ticket (customer_id);
CREATE INDEX ticket_team_idx           ON lumina.ticket (team_id);
CREATE INDEX comment_ticket_idx        ON lumina.ticket_comment (ticket_id);
CREATE INDEX event_ticket_idx          ON lumina.ticket_event (ticket_id);

-- Multi-column: equality on team, then status — leftmost-prefix serves team-only.
CREATE INDEX ticket_team_status_idx    ON lumina.ticket (team_id, status);

-- Covering index for the agent-workload query; INCLUDE carries payload columns
-- so the read never touches the heap. Its leftmost column also serves the
-- assigned_agent_id FK, which is why the plain FK index was dropped.
CREATE INDEX ticket_workload_idx
    ON lumina.ticket (assigned_agent_id, status)
    INCLUDE (priority, created_at);

-- Partial: the hot 8% (open tickets) at 1/11th the size of a full index.
CREATE INDEX ticket_open_created_idx
    ON lumina.ticket (created_at)
    WHERE status = 'open';

-- Expression: case-insensitive subject lookups must match the expression.
CREATE INDEX ticket_subject_lower_idx  ON lumina.ticket (lower(subject));

-- Specialists: GIN for containment on documents; BRIN for the append-only clock.
CREATE INDEX ticket_custom_fields_gin  ON lumina.ticket USING gin (custom_fields);
CREATE INDEX event_occurred_brin       ON lumina.ticket_event USING brin (occurred_at);
