"""normalize.py -- make captured psql output comparable across runs.

Reads psql output on stdin (or --file), writes normalized text on stdout.

Modes:
  match  (default)  strip only what is legitimately volatile: timing lines,
                    memory/disk usage, PIDs and transaction ids. Everything
                    else must match byte for byte.
  shape             additionally mask the numbers inside (cost=...), (actual...)
                    and rows=/width= annotations -- for EXPLAIN listings where
                    the SHAPE of the plan is the lesson and exact costs are not.

--sort sorts the data rows of a result grid. Use it for listings with no
ORDER BY: an unordered result set has no defined row order, and comparing it
literally would produce flaky failures.
"""

import argparse
import re
import sys

VOLATILE = [
    re.compile(r"^\s*(Planning|Execution) Time: .*$"),
    re.compile(r"^\s*Planning:\s*$"),
    re.compile(r"^\s*Buffers: .*$"),
    re.compile(r"^\s*I/O Timings: .*$"),
    re.compile(r"^\s*JIT:.*$"),
    re.compile(r"^\s*(Functions|Options|Timing): .*$"),          # JIT sub-lines
    re.compile(r"^\s*Sort (Space Used|Method): .*$"),
    re.compile(r"^\s*(Peak )?Memory( Usage)?: .*$"),
    re.compile(r"^\s*Disk( Usage)?: .*$"),
    re.compile(r"^\s*Worker \d+: .*$"),
    re.compile(r"^\s*Heap Fetches: .*$"),
    re.compile(r"^\s*Storage: .*$"),          # Memory/Disk + Maximum Storage kB
    re.compile(r"^\s*Buckets: .*$"),          # hash sizing = machine weather
    re.compile(r"^\s*Batches: .*$"),
]

SHAPE_MASKS = [
    (re.compile(r"cost=\d+\.\d+\.\.\d+\.\d+"), "cost=N..N"),
    (re.compile(r"actual time=\d+\.\d+\.\.\d+\.\d+"), "actual time=N..N"),
    (re.compile(r"\brows=\d+"), "rows=N"),
    (re.compile(r"\bwidth=\d+"), "width=N"),
    (re.compile(r"\bloops=\d+"), "loops=N"),
]

# A 768-dim vector literal is deterministic but 6000+ characters long; printed
# in an EXPLAIN Sort Key / Order By it would bury the plan and blow the line
# budget. Collapse any '[...]'::vector literal to a short, stable placeholder in
# BOTH modes — this shortens, it does not hide volatility (the values are fixed).
ALWAYS_MASKS = [
    (re.compile(r"'\[-?\d[\d.,eE+\-]*\]'::vector"), "'[...]'::vector"),
]

PID_MASKS = [
    (re.compile(r"\bpid[= ]\d+", re.IGNORECASE), "pid=N"),
    (re.compile(r"\bPID \d+"), "PID N"),
    (re.compile(r"\bxid[= ]\d+", re.IGNORECASE), "xid=N"),
    # Deadlock reports name backend pids and xids in prose form (both cases).
    (re.compile(r"\b[Pp]rocess \d+"), "process N"),
    (re.compile(r"\btransaction \d+"), "transaction N"),
    (re.compile(r"pg_temp_\d+"), "pg_temp_N"),
    # psql -f prefixes messages with "psql:<absolute path>:<line>: [error:] ".
    # A reader at the interactive prompt never sees that prefix, and the path
    # is machine-specific — strip it so captures match the reader experience.
    (re.compile(r"^psql:.*?:\d+:\s*(error:\s*)?"), ""),
]


def normalize(text: str, mode: str, sort_rows: bool) -> str:
    lines = []
    for line in text.splitlines():
        line = line.rstrip()
        if any(rx.match(line) for rx in VOLATILE):
            continue
        for rx, repl in ALWAYS_MASKS:
            line = rx.sub(repl, line)
        for rx, repl in PID_MASKS:
            line = rx.sub(repl, line)
        if mode == "shape":
            for rx, repl in SHAPE_MASKS:
                line = rx.sub(repl, line)
        lines.append(line)

    # Drop leading/trailing blank lines so trailing-newline differences never matter.
    while lines and not lines[0]:
        lines.pop(0)
    while lines and not lines[-1]:
        lines.pop()

    if sort_rows:
        lines = _sort_grid_rows(lines)

    return "\n".join(lines) + "\n"


def _sort_grid_rows(lines: list[str]) -> list[str]:
    """Sort the data rows of each psql result grid independently, leaving
    headers, separators, and (N rows) trailers in place. A multi-statement
    listing produces multiple grids in one output; sorting across grid
    boundaries would interleave them into nonsense, so each grid's data block
    ends at its own trailer or at a blank line. Unrecognized shapes pass
    through untouched -- never guess."""
    out: list[str] = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        is_sep = bool(re.fullmatch(r"[-+ ]+", line) and "-" in line)
        if not is_sep or i == 0:
            out.append(line)
            i += 1
            continue
        # Data block: everything until this grid's trailer or a blank line.
        out.append(line)
        j = i + 1
        block: list[str] = []
        while j < n:
            nxt = lines[j]
            if not nxt.strip() or re.fullmatch(r"\(\d+ rows?\)", nxt.strip()):
                break
            block.append(nxt)
            j += 1
        out.extend(sorted(block))
        i = j
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--mode", choices=["match", "shape"], default="match")
    ap.add_argument("--sort", action="store_true", help="sort result-grid data rows")
    ap.add_argument("--file", help="read from a file instead of stdin")
    args = ap.parse_args()

    raw = open(args.file, encoding="utf-8").read() if args.file else sys.stdin.read()
    # PowerShell pipes prepend a BOM depending on $OutputEncoding — never let it
    # become a byte-comparison difference.
    raw = raw.lstrip("﻿")
    sys.stdout.write(normalize(raw, args.mode, args.sort))


if __name__ == "__main__":
    main()
