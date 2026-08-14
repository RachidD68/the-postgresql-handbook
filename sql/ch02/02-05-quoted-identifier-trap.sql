-- Listing 2.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
-- Intentionally fails with SQLSTATE 42P01
-- Looks fine. Is a trap.
CREATE TABLE "TicketNote" (
    "NoteId"  bigint,
    "Body"    text
);

-- Now every query must quote, forever, with exactly this casing:
SELECT "NoteId", "Body" FROM "TicketNote";

-- While the unquoted name never worked at all — it folds to lowercase:
SELECT NoteId FROM TicketNote;
