-- Listing 17.5 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch17/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 17
GRANT SELECT (id, reference, subject, status, priority)
    ON ticket TO support_agent;
