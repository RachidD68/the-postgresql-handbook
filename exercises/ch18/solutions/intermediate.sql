-- Solution to Exercise 18.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 18

CREATE TABLE comment_scratch AS SELECT * FROM ticket_comment;

-- Pass 1: every row updated, then measured.
UPDATE comment_scratch SET author_kind = author_kind;
SELECT pg_stat_force_next_flush();
SELECT n_live_tup, n_dead_tup,
       pg_size_pretty(pg_relation_size('comment_scratch')) AS on_disk
FROM pg_stat_user_tables WHERE relname = 'comment_scratch';

-- Recycle between passes, as autovacuum would:
VACUUM comment_scratch;

-- Pass 2:
UPDATE comment_scratch SET author_kind = author_kind;
SELECT pg_stat_force_next_flush();
SELECT n_live_tup, n_dead_tup,
       pg_size_pretty(pg_relation_size('comment_scratch')) AS on_disk
FROM pg_stat_user_tables WHERE relname = 'comment_scratch';

VACUUM comment_scratch;

-- Pass 3:
UPDATE comment_scratch SET author_kind = author_kind;
SELECT pg_stat_force_next_flush();
SELECT n_live_tup, n_dead_tup,
       pg_size_pretty(pg_relation_size('comment_scratch')) AS on_disk
FROM pg_stat_user_tables WHERE relname = 'comment_scratch';

-- Final plain VACUUM: dead tuples collected, size unchanged.
VACUUM comment_scratch;
SELECT pg_stat_force_next_flush();
SELECT n_live_tup, n_dead_tup,
       pg_size_pretty(pg_relation_size('comment_scratch')) AS on_disk
FROM pg_stat_user_tables WHERE relname = 'comment_scratch';

-- VACUUM FULL: the file itself shrinks.
VACUUM FULL comment_scratch;
SELECT pg_size_pretty(pg_relation_size('comment_scratch')) AS on_disk;

DROP TABLE comment_scratch;

-- Measured: every pass reports 120 live / 120 dead at a flat 40 kB — the
-- VACUUM between passes recycled the dead space, so three full-table
-- rewrites never grew the file. The final VACUUM FULL compacted it to
-- 24 kB. The two-sentence moral: plain VACUUM reclaims dead versions for
-- REUSE (n_dead_tup to 0, size flat) while only VACUUM FULL returns bytes
-- to the filesystem; the number autovacuum keeps low is n_dead_tup, and
-- keeping it low DURING churn is exactly why the file never ballooned.
