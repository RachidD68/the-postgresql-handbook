# The PostgreSQL Handbook — Companion Code

The Lumina Helpdesk database, every SQL listing, and the exercise solutions for
*The PostgreSQL Handbook: From First Query to Production Database* (PostgreSQL 18).

## Quick start

```
docker compose up -d
.\scripts\reset-to-chapter.ps1 -Chapter 23
```

That gives you the exact database every listing in the book was verified against.
No Docker? Appendix A covers native installs; the scripts work identically —
they connect via the standard `PGHOST` / `PGPORT` / `PGUSER` / `PGPASSWORD`
environment variables (default `localhost:5432` as `postgres`).

## Layout

| Path | What it is |
|---|---|
| `docker-compose.yml` | PostgreSQL 18 (`pgvector/pgvector:pg18`) + pgAdmin — the Chapter 1 environment |
| `schema/` | `010-core-schema.sql` (Chapter 2) plus additive migrations, one per schema-changing chapter |
| `seed/` | Deterministic data: `seed-core.sql` (the 40 tickets the book narrates), `seed-bulk.sql` (80k tickets for the performance chapters) |
| `sql/chNN/` | **Generated** — every listing printed in chapter NN, exactly as printed. Do not edit; they are emitted from the book's source |
| `exercises/chNN/` | Exercise solutions (basic / intermediate / challenge) |
| `scripts/` | `reset-to-chapter.ps1 -Chapter N` — rebuild the database to the state chapter N expects |
| `tools/` | The verification harness the book was built with |
| `src/` | One small C# solution for Chapters 21–23 (Npgsql, EF Core, pgvector) |
| `config/` | The planner settings the book's `EXPLAIN` output was captured under |

## Chapter state

Chapter state is a pure function of N: `reset-to-chapter.ps1 -Chapter N` gives you
the database as it stands when chapter N *opens* — the core schema (from Chapter 3
onward), every migration from earlier chapters, and the seeds N calls for, then
`VACUUM (ANALYZE)`. The chapter's own DDL is yours to type as you follow along.
If a listing from Chapter 9 misbehaves, reset to 9 — never assume state left over
from other chapters.

## Determinism

Seeds use fixed ids, fixed timestamps (the book's "today" is
`2026-01-15 09:00:00+00`), and prime-modulus arithmetic instead of `random()`, so
your result grids match the book's byte for byte. The reset script pins
`jit = off`, `work_mem`, and `random_page_cost` at the database level so your
`EXPLAIN` output matches too.
