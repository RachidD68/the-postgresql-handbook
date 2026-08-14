-- Solution to Exercise 13.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 13

CREATE TABLE team_open_count (
    team_id       bigint PRIMARY KEY,
    open_tickets  bigint NOT NULL
);

-- Seed from the truth:
INSERT INTO team_open_count (team_id, open_tickets)
SELECT tm.id, count(t.id) FILTER (WHERE t.status = 'open')
FROM team AS tm
LEFT JOIN ticket AS t ON t.team_id = tm.id
GROUP BY tm.id;

-- The trigger: TG_OP branches, and the UPDATE arm handles both a status
-- flip and a team transfer by treating them as leave-OLD, enter-NEW.
CREATE FUNCTION maintain_team_open_count()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') AND OLD.status = 'open' THEN
        UPDATE team_open_count
        SET open_tickets = open_tickets - 1
        WHERE team_id = OLD.team_id;
    END IF;
    IF TG_OP IN ('INSERT', 'UPDATE') AND NEW.status = 'open' THEN
        UPDATE team_open_count
        SET open_tickets = open_tickets + 1
        WHERE team_id = NEW.team_id;
    END IF;
    RETURN NULL;   -- AFTER trigger: the return value is ignored
END;
$$;

CREATE TRIGGER ticket_team_open_count
    AFTER INSERT OR UPDATE OR DELETE ON ticket
    FOR EACH ROW
    EXECUTE FUNCTION maintain_team_open_count();

-- Prove it tracks two status flips:
SELECT * FROM team_open_count ORDER BY team_id;

UPDATE ticket SET status = 'resolved', resolved_at = '2026-01-15 09:00:00+00'
WHERE reference = 'LUM-1036';
SELECT * FROM team_open_count ORDER BY team_id;   -- team 2 down by one

UPDATE ticket SET status = 'open', resolved_at = NULL
WHERE reference = 'LUM-1036';
SELECT * FROM team_open_count ORDER BY team_id;   -- team 2 back up

-- Cross-check against recomputing:
SELECT tm.id, count(t.id) FILTER (WHERE t.status = 'open') AS open_tickets
FROM team AS tm
LEFT JOIN ticket AS t ON t.team_id = tm.id
GROUP BY tm.id
ORDER BY tm.id;

-- The argument this chapter armed: this is derived state you can recompute
-- with one GROUP BY, so it should be a view until that view is PROVEN too
-- slow — and proven means Chapter 16 numbers, not vibes. The trigger version
-- wins only when the count is read vastly more often than tickets change
-- AND the recompute is measurably too slow at read time; it costs two extra
-- row updates (and their lock contention) on every ticket write, forever.
