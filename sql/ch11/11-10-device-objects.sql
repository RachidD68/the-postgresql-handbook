-- Listing 11.10 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch11/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 11
UPDATE ticket
SET custom_fields = custom_fields
        || '{"device": {"os": "iOS", "os_version": "19.2", "app_version": "4.8.1"}}'
WHERE reference = 'LUM-1004';

UPDATE ticket
SET custom_fields = custom_fields
        || '{"device": {"os": "Android", "os_version": "17", "app_version": "4.7.0"}}'
WHERE reference = 'LUM-1033';
