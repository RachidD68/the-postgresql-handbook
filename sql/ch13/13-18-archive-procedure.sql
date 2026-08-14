-- Listing 13.18 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE TABLE event_scratch AS SELECT * FROM ticket_event;
CREATE TABLE event_archive AS SELECT * FROM ticket_event WHERE false;

CREATE PROCEDURE archive_old_events(cutoff timestamptz, batch_size int)
LANGUAGE plpgsql
AS $$
DECLARE
    moved int;
BEGIN
    LOOP
        WITH batch AS (
            DELETE FROM event_scratch
            WHERE id IN (SELECT id FROM event_scratch
                         WHERE occurred_at < cutoff
                         ORDER BY id
                         LIMIT batch_size)
            RETURNING *
        )
        INSERT INTO event_archive SELECT * FROM batch;

        GET DIAGNOSTICS moved = ROW_COUNT;
        RAISE NOTICE 'archived % events', moved;
        EXIT WHEN moved < batch_size;
        COMMIT;
    END LOOP;
END;
$$;
