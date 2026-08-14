-- Listing 7.13 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch07/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 7
INSERT INTO tag (name, description)
VALUES ('beta-program', 'Early-access feature feedback');

SELECT tg.name AS tag_name, tt.ticket_id
FROM tag AS tg
FULL OUTER JOIN ticket_tag AS tt ON tt.tag_id = tg.id
WHERE tg.id IS NULL OR tt.ticket_id IS NULL;
