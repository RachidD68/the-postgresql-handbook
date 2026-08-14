-- Solution to Exercise 5.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 5

CREATE TABLE numeric_edges (
    small_v  smallint,
    int_v    integer,
    big_v    bigint,
    exact_v  numeric(6,2)
);

-- The largest happy values:
INSERT INTO numeric_edges
VALUES (32767, 2147483647, 9223372036854775807, 9999.99);

-- Each nudge over the edge fails with SQLSTATE 22003, but the messages split
-- into two families — "out of range" for the machine integers, "numeric
-- field overflow" for the exact type:
INSERT INTO numeric_edges (small_v) VALUES (32768);
-- ERROR:  smallint out of range
INSERT INTO numeric_edges (int_v) VALUES (2147483648);
-- ERROR:  integer out of range
INSERT INTO numeric_edges (big_v) VALUES (9223372036854775808);
-- ERROR:  bigint out of range
INSERT INTO numeric_edges (exact_v) VALUES (10000.00);
-- ERROR:  numeric field overflow
-- DETAIL: A field with precision 6, scale 2 must round to an absolute
--         value less than 10^4.

-- Surprise two: too many DECIMAL places do not error — they round to scale.
INSERT INTO numeric_edges (exact_v) VALUES (1234.567) RETURNING exact_v;
-- Returns 1234.57. Precision caps total digits (hard error); scale governs
-- fractional digits (silent rounding) — friendlier, and occasionally worse.

DROP TABLE numeric_edges;
