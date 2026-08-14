-- Solution to Exercise 18.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 18
-- Run with:    psql -d lumina -f challenge.sql   (the Monday runbook)

\echo === 1. Blocked queries and their blockers ===
SELECT pid, state, wait_event_type,
       pg_blocking_pids(pid) AS blocked_by,
       left(query, 40) AS running
FROM pg_stat_activity
WHERE cardinality(pg_blocking_pids(pid)) > 0
ORDER BY pid;
-- Bad: any rows at all that persist between two runs — a lock convoy,
-- with the pids to chase.

\echo === 2. Oldest open transaction ===
SELECT pid, now() - xact_start AS open_for, left(query, 40) AS running
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_start
LIMIT 1;
-- Bad: open_for measured in hours — that transaction is pinning vacuum's
-- cleanup horizon for the whole database (the Chapter 14 warning).

\echo === 3. Five most-written tables ===
SELECT relname,
       n_tup_ins + n_tup_upd + n_tup_del AS writes,
       n_dead_tup
FROM pg_stat_user_tables
ORDER BY writes DESC
LIMIT 5;
-- Bad: a table you did not expect in the top five, or n_dead_tup rivaling
-- live rows — autovacuum is losing that table's race.

\echo === 4. Cache hit ratio ===
SELECT datname,
       round(100.0 * blks_hit / nullif(blks_hit + blks_read, 0), 2)
           AS cache_hit_pct
FROM pg_stat_database
WHERE datname = 'lumina';
-- Bad: a ratio drifting below ~99% on a steady workload — the working set
-- no longer fits shared_buffers, and disk reads are becoming routine.
