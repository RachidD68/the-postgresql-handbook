-- Solution to Exercise 2.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 3
-- (State 3 is Chapter 2's finished work product: the core schema exists.)

CREATE TABLE tag_practice (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         text NOT NULL UNIQUE,
    description  text NOT NULL
);

-- Inspect: \d tag_practice shows both indexes the constraints created —
-- tag_practice_pkey and tag_practice_name_key.

DROP TABLE tag_practice;
