# Exercise solutions

Three solutions per chapter — `basic`, `intermediate`, `challenge` — for all 23
chapters, matching Appendix D of the book. Chapters 1–20 and 23 are `.sql`;
Chapters 21 and 22 are `.cs`, because those chapters are C#.

Each file names the state it expects in its header:

```
-- Solution to Exercise 15.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 15
```

Reset to that state first, then run the file:

```
.\scripts\reset-to-chapter.ps1 -Chapter 15     # Windows
./scripts/reset-to-chapter.sh 15               # macOS / Linux

psql -d lumina -f exercises/ch15/solutions/intermediate.sql
```

## Some solutions fail on purpose

A few exercises ask you to prove that PostgreSQL *refuses* something — an
overflow, a constraint violation, a rolled-back transaction. Their solutions
contain statements that are supposed to raise an error, with the expected
SQLSTATE named in a comment right above them:

| Solution | Deliberate error |
|---|---|
| `ch05/basic` | numeric overflow across the integer family |
| `ch05/challenge` | uncommitted enum value rejected |
| `ch06/basic` | named CHECK constraint violation |
| `ch06/intermediate` | `ON DELETE RESTRICT` refusing a delete |
| `ch14/basic` | `1/0` sabotage proving atomicity |
| `ch14/intermediate` | `SAVEPOINT` recovery after a failed statement |
| `ch17/basic` | two flavors of `42501` insufficient privilege |

Run these under `psql` without `ON_ERROR_STOP=1` if you want to see every
statement execute; with it, psql stops at the first deliberate error, which is
also a fine way to read them one failure at a time. Either way, the error is the
answer — not a bug in the file.
