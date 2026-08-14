-- Listing 9.24 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch09/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 9
CREATE TABLE loop_demo (id int, next_id int);
INSERT INTO loop_demo (id, next_id) VALUES (1, 2), (2, 1);

WITH RECURSIVE walk AS (
    SELECT id, next_id FROM loop_demo WHERE id = 1
  UNION
    SELECT d.id, d.next_id
    FROM loop_demo AS d
    JOIN walk ON d.id = walk.next_id
)
SELECT * FROM walk;
