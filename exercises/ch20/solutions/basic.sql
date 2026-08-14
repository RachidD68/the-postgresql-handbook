-- Solution to Exercise 20.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 20

SELECT pg_wal_lsn_diff('0/5A0003E8', '0/5A000000') AS lag_bytes;
-- 1000 bytes.

-- The alarm belongs on replay_lag (seconds), not bytes. 1,000 bytes is
-- nothing; 4.2 seconds is a user reading a stale pricing page — staleness
-- is experienced in time. And the byte number can mislead in BOTH
-- directions: a tiny byte lag on a quiet primary can still be minutes old,
-- because nothing new is being written to measure against.
