-- Listing 13.21 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
ALTER TABLE ticket
    ADD COLUMN updated_at timestamptz;

CREATE FUNCTION touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER ticket_touch_updated_at
    BEFORE UPDATE ON ticket
    FOR EACH ROW
    EXECUTE FUNCTION touch_updated_at();
