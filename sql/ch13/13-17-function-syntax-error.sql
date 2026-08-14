-- Listing 13.17 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch13/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 13
-- Intentionally fails with SQLSTATE 42601
CREATE FUNCTION fn_broken(t_id bigint)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
    RETRUN 'this never compiles';
END;
$$;
