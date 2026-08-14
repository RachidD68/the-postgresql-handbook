-- Listing 6.27 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch06/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 6
BEGIN;  -- start a transaction: a group of statements judged together

CREATE TABLE desk_assignment (
    agent_name text NOT NULL,
    desk_no    integer UNIQUE DEFERRABLE INITIALLY IMMEDIATE
);
INSERT INTO desk_assignment (agent_name, desk_no)
VALUES ('Priya', 1), ('Marcus', 2);

SET CONSTRAINTS ALL DEFERRED;   -- judge me at commit, not per statement
UPDATE desk_assignment SET desk_no = 2 WHERE agent_name = 'Priya';
UPDATE desk_assignment SET desk_no = 1 WHERE agent_name = 'Marcus';

ROLLBACK;  -- undo the whole demo; COMMIT would have kept the swap
