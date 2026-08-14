-- Listing 13.14 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE FUNCTION fn_resolution_summary(t_id bigint)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    t ticket%ROWTYPE;
BEGIN
    SELECT * INTO t FROM ticket WHERE id = t_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'no ticket with id %', t_id;
    END IF;

    IF t.resolution_minutes IS NOT NULL THEN
        RETURN format('resolved in %s minutes', t.resolution_minutes);
    ELSIF t.status = 'open' THEN
        RETURN format('open since %s', t.created_at::date);
    ELSE
        RETURN format('%s, unresolved', t.status);
    END IF;
END;
$$;
