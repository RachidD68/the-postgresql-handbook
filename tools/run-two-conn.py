"""run-two-conn.py -- drive one listing across TWO live database sessions.

Chapter 14's concurrency demos need two connections with a scripted
interleave. A listing file marks its steps with session comments:

    -- [A]                       run on session A, wait for it to finish
    -- [B] blocks                send on B, do NOT wait (it will block server-side)
    -- [B] resumes               collect B's pending result now (no new SQL)
    -- [A] expect-error 40P01    step must FAIL with this SQLSTATE
    -- [A] resumes expect-error 40P01   (the two compose)

Everything between one marker and the next is that step's SQL (which may be
several statements). Each session runs on its own connection in its own
thread, in autocommit mode -- BEGIN/COMMIT in the listing text control
transactions exactly as they would at a psql prompt. The driver prints an
interleaved transcript, each line prefixed 'A| ' or 'B| ', with query results
formatted psql-style. When a step is sent without waiting, the transcript
notes it -- which is exactly what the reader's second terminal shows:
nothing, until it unblocks.

Requires psycopg 3 (pip install "psycopg[binary]").

Exit code 0 iff every step behaved as declared (errors only where declared,
with the declared SQLSTATE). Used by verify-listings.ps1 and
capture-output.ps1 for run='two-conn' manifest entries.
"""

import argparse
import os
import queue
import re
import sys
import threading

import psycopg

MARKER = re.compile(
    r"^--\s*\[(?P<sess>[AB])\]"
    r"(?P<blocks>\s+blocks)?"
    r"(?P<resumes>\s+resumes)?"
    r"(?:\s+expect-error\s+(?P<code>\w+))?\s*$"
)
STEP_TIMEOUT = 25  # seconds; a genuinely blocked step never waits this long


# ── psql-style result formatting ────────────────────────────────────
def fmt_value(v) -> str:
    if v is None:
        return ""
    if isinstance(v, bool):
        return "t" if v else "f"
    return str(v)


def is_numeric(v) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def fmt_grid(columns, rows) -> list[str]:
    """Render a result set the way psql's aligned mode does: headers centered,
    numeric columns right-aligned, text left-aligned, (N rows) trailer."""
    headers = [c.name for c in columns]
    cells = [[fmt_value(v) for v in row] for row in rows]
    right = [all(is_numeric(row[i]) for row in rows if row[i] is not None) and
             any(row[i] is not None for row in rows)
             for i in range(len(headers))] if rows else [False] * len(headers)
    widths = [max(len(headers[i]), *(len(r[i]) for r in cells)) if cells
              else len(headers[i]) for i in range(len(headers))]

    def center(s, w):
        pad = w - len(s)
        left = pad // 2
        return " " * left + s + " " * (pad - left)

    out = [" " + " | ".join(center(headers[i], widths[i]) for i in range(len(headers)))]
    out.append("-+-".join("-" * (w + 2) for w in widths)[1:-1]
               if len(headers) > 1 else "-" * (widths[0] + 2))
    for r in cells:
        out.append(" " + " | ".join(
            r[i].rjust(widths[i]) if right[i] else r[i].ljust(widths[i])
            for i in range(len(headers))))
    out.append(f"({len(cells)} row{'s' if len(cells) != 1 else ''})")
    out.append("")
    return out


def fmt_error(e: psycopg.Error) -> list[str]:
    d = e.diag
    lines = [f"ERROR:  {d.sqlstate}: {d.message_primary}"]
    # Diag fields can be multi-line (deadlock DETAILs are); split them so every
    # transcript line carries its session prefix.
    if d.message_detail:
        lines.extend(f"DETAIL:  {d.message_detail}".splitlines())
    if d.message_hint:
        lines.extend(f"HINT:  {d.message_hint}".splitlines())
    if d.context:
        lines.extend(f"CONTEXT:  {d.context}".splitlines())
    return lines


# ── session worker ──────────────────────────────────────────────────
class Session(threading.Thread):
    """One connection, executing queued SQL steps serially."""

    def __init__(self, name: str, dsn: str):
        super().__init__(daemon=True)
        self.name_ = name
        self.conn = psycopg.connect(dsn, autocommit=True)
        self.inbox: queue.Queue[str] = queue.Queue()
        self.outbox: queue.Queue[list[str]] = queue.Queue()
        self.start()

    def run(self):
        while True:
            sql = self.inbox.get()
            if sql is None:
                return
            lines: list[str] = []
            try:
                with self.conn.cursor() as cur:
                    cur.execute(sql)
                    while True:
                        if cur.description:
                            lines.extend(fmt_grid(cur.description, cur.fetchall()))
                        elif cur.statusmessage:
                            lines.append(cur.statusmessage)
                        if not cur.nextset():
                            break
                # NOTICEs arrive via connection; surface any queued diagnostics.
            except psycopg.Error as e:
                lines.extend(fmt_error(e))
                # Leave transaction state exactly as psql would: aborted until
                # the script says ROLLBACK.
            self.outbox.put(lines)

    def send(self, sql: str):
        self.inbox.put(sql)

    def collect(self) -> list[str]:
        try:
            return self.outbox.get(timeout=STEP_TIMEOUT)
        except queue.Empty:
            raise TimeoutError(
                f"session {self.name_}: step timed out -- "
                f"a step that blocks must be marked 'blocks'")

    def close(self):
        self.inbox.put(None)
        try:
            self.conn.close()
        except Exception:
            pass


# ── step parsing and orchestration ──────────────────────────────────
def parse_steps(text: str):
    steps = []
    current = None
    for line in text.splitlines():
        m = MARKER.match(line.strip())
        if m:
            if current:
                steps.append(current)
            current = {"sess": m.group("sess"), "blocks": bool(m.group("blocks")),
                       "resumes": bool(m.group("resumes")), "code": m.group("code"),
                       "sql": []}
        elif current is not None:
            current["sql"].append(line)
    if current:
        steps.append(current)
    if not steps:
        raise SystemExit("no -- [A] / -- [B] step markers found")
    return steps


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("file", help="listing .sql file with step markers")
    ap.add_argument("--db", default="lumina")
    args = ap.parse_args()

    text = open(args.file, encoding="utf-8-sig").read()
    steps = parse_steps(text)

    host = os.environ.get("PGHOST", "localhost")
    user = os.environ.get("PGUSER", "postgres")
    dsn = f"host={host} user={user} dbname={args.db}"

    sessions = {"A": Session("A", dsn), "B": Session("B", dsn)}
    failures: list[str] = []
    transcript: list[str] = []

    def emit(name: str, lines: list[str], expected: str | None):
        got_error = any(ln.startswith("ERROR") for ln in lines)
        joined = "\n".join(lines)
        if expected:
            if not got_error:
                failures.append(f"[{name}] expected {expected}, but step succeeded")
            elif expected not in joined:
                failures.append(f"[{name}] failed, but not with {expected}: {joined}")
        elif got_error:
            failures.append(f"[{name}] unexpected error: {joined}")
        for ln in lines:
            transcript.append(f"{name}| {ln}" if ln else f"{name}|")

    try:
        for step in steps:
            s = sessions[step["sess"]]
            sql = "\n".join(step["sql"]).strip()

            if step["resumes"]:
                if sql:
                    raise SystemExit(f"[{s.name_}] 'resumes' steps must not carry SQL")
                emit(s.name_, s.collect(), step["code"])
                continue

            if not sql:
                raise SystemExit(f"[{s.name_}] step has no SQL")
            s.send(sql)

            if step["blocks"]:
                transcript.append(f"{s.name_}| (now waiting -- this terminal just hangs)")
                continue

            emit(s.name_, s.collect(), step["code"])
    finally:
        for s in sessions.values():
            s.close()

    while transcript and not transcript[-1].rstrip("AB| "):
        transcript.pop()
    print("\n".join(transcript))
    if failures:
        print("\n".join("TWO-CONN FAIL: " + f for f in failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
