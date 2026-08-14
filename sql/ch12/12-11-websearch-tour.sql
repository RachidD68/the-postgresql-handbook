-- Listing 12.11 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch12/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 12
SELECT websearch_to_tsquery('english', 'export crash')      AS both_words,
       websearch_to_tsquery('english', 'export or crash')   AS either_word,
       websearch_to_tsquery('english', '"blank page"')      AS exact_phrase,
       websearch_to_tsquery('english', 'export -mobile')    AS minus_mobile;
