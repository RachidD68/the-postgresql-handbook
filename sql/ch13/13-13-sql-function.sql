-- Listing 13.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
CREATE FUNCTION fn_ticket_age(t_id bigint, as_of timestamptz DEFAULT now())
RETURNS interval
LANGUAGE sql
AS $$
    SELECT as_of - created_at
    FROM ticket
    WHERE id = t_id;
$$;
