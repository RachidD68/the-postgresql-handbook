-- Solution to Exercise 20.3 — The PostgreSQL Handbook, Appendix D.
-- (Routing exercise — decisions and defenses; no SQL to run.)

-- (a) mv_monthly_stats dashboard -> REPLICA + transaction pooling.
--     It reads a materialized view that is itself a snapshot; a reader
--     tolerant of REFRESH staleness cannot object to replication lag, and
--     short read-only transactions are transaction pooling's best case.

-- (b) ticket page right after the customer posts a comment -> PRIMARY +
--     transaction pooling, WITH SET LOCAL app.customer_id inside every
--     transaction. Read-your-own-writes forbids the replica (the comment
--     may not have replayed yet). The RLS complication: Chapter 17's
--     policy reads current_setting('app.customer_id'), and under
--     transaction pooling the next transaction may run on a DIFFERENT
--     server session — a plain SET leaks tenant A's identity to tenant
--     B's queries. SET LOCAL dies at commit, which is exactly the point.

-- (c) Chapter 12's search box -> REPLICA + transaction pooling.
--     Search results are inherently a moment old the instant they render;
--     nobody notices one more second, and offloading the tsquery work is
--     what read replicas are for.
