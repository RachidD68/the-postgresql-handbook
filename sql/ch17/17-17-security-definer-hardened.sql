-- Listing 17.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
CREATE FUNCTION fn_my_tickets()
RETURNS TABLE (reference text, subject text, status text)
LANGUAGE sql
SECURITY DEFINER
SET search_path = lumina, pg_temp
AS $$
    SELECT reference, subject, status
    FROM ticket
    WHERE customer_id = current_setting('app.customer_id', true)::bigint
    ORDER BY reference;
$$;

REVOKE EXECUTE ON FUNCTION fn_my_tickets() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_my_tickets() TO lumina_app;
