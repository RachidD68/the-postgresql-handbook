-- select1.sql — the cheapest possible query, used by Chapter 20's pgbench
-- connection-cost demo:  pgbench -h localhost -U postgres -d lumina -n -C -t 50 -f tools/select1.sql
SELECT 1;
