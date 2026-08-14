-- Listing 13.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE FUNCTION log_status_change()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
    VALUES (NEW.id, 'status_changed',
            jsonb_build_object('from', OLD.status, 'to', NEW.status),
            now());
    RETURN NEW;
END;
$$;

CREATE TRIGGER ticket_audit_status
    AFTER UPDATE OF status ON ticket
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION log_status_change();
