#!/usr/bin/env python3
"""verify-book-vs-repo.py - drift checker for the hand-maintained seams between
the book (Book/chapters/ChNN/render.js, Book/appendices/X/render.js) and this
companion repository.

Most printed code cannot drift: sqlBlock() with an id is GENERATED into
CodeSample/sql/chNN/*.sql at render time, and psqlBlock(expected('NN-MM'))
READS CodeSample/sql/chNN/.expected/*.txt at render time. Those seams are
structurally sound and this tool deliberately ignores them.

Five seams are hand-maintained on both sides and nothing else checks them:

  csharp    Ch21/22/23 codeBlocks vs src/Lumina.{Data,EfCore,Search}/*.cs
  exercise  Appendix D's 69 solutions vs exercises/chNN/solutions/{tier}.{sql,cs}
  schema    schema/migrations/0NN-chMM-*.sql (and 010-core-schema.sql) replaying
            chapter listings, with lumina. qualification added
  manifest  Book/chapters/ChNN/ChNN.listings.json (generated) vs
            sql/manifests/ChNN.listings.json (hand-copied)
  config    Ch01's abridged docker-compose.yml listing, and every -c key=value in
            the compose command vs config/book-settings.conf

The book text is obtained by running Book/_shared/extract_blocks.js under node.
That extractor patches bookStyle in place and stubs saveDocument, so nothing is
written and no database is touched. This tool is read-only apart from
--baseline, which writes tools/book-repo-baseline.json.

Usage:
    python verify-book-vs-repo.py [--chapter N]... [--category NAME]...
                                  [--verbose] [--suggest] [--baseline]

Exit codes:
    0  clean (only MATCH / COMPOSITE / INFO / ACCEPTED / BOOK-PRINTS-NOTHING)
    1  at least one unaccepted DIFFERS or MISSING
    2  tool error, or an UNMAPPED Ch21-23 code block
"""

from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

# --------------------------------------------------------------------------
# Paths
# --------------------------------------------------------------------------

TOOLS = Path(__file__).resolve().parent
CS = TOOLS.parent                      # CodeSample/
ROOT = CS.parent                       # The PostgreSQL Handbook/
BOOK = ROOT / "Book"
EXTRACTOR = BOOK / "_shared" / "extract_blocks.js"
MAP_PATH = TOOLS / "book-repo-map.json"
BASELINE_PATH = TOOLS / "book-repo-baseline.json"

CSHARP_CHAPTERS = (21, 22, 23)
CONFIG_CHAPTER = 1                     # docker-compose.yml belongs to Chapter 1
APPENDIX_D_CHAPTER = None              # exercises carry their own chapter number

CATEGORIES = ("csharp", "exercise", "schema", "manifest", "config")

# States that never fail the run.
OK_STATES = {"MATCH", "COMPOSITE", "INFO", "ACCEPTED", "BOOK-PRINTS-NOTHING"}
# States that fail with exit 1.
FAIL_STATES = {"DIFFERS", "DIFFERS (whitespace only)", "DIFFERS (EOL)", "MISSING"}
# States that fail with exit 2.
HARD_STATES = {"UNMAPPED", "ERROR"}


class ToolError(RuntimeError):
    """Anything that means the checker itself could not run."""


# --------------------------------------------------------------------------
# Normalizers
# --------------------------------------------------------------------------

def norm_text(t: str) -> str:
    """Strip BOM, normalize line endings, drop trailing whitespace per line."""
    t = t.replace("﻿", "").replace("\r\n", "\n").replace("\r", "\n")
    return "\n".join(line.rstrip() for line in t.split("\n"))


def collapse_ws(t: str) -> str:
    """Every whitespace run becomes one space. Case preserved."""
    return re.sub(r"\s+", " ", norm_text(t)).strip()


def strip_sql_comments(t: str) -> str:
    """Remove -- line comments and /* */ block comments, string-literal aware."""
    out = []
    i, n = 0, len(t)
    while i < n:
        c = t[i]
        if c in "'\"":
            q = c
            out.append(c)
            i += 1
            while i < n:
                if t[i] == q:
                    if i + 1 < n and t[i + 1] == q:      # '' / "" escape
                        out.append(q)
                        out.append(q)
                        i += 2
                        continue
                    out.append(q)
                    i += 1
                    break
                out.append(t[i])
                i += 1
            continue
        if t.startswith("--", i):
            j = t.find("\n", i)
            i = n if j < 0 else j
            out.append(" ")
            continue
        if t.startswith("/*", i):
            depth, i = 1, i + 2
            while i < n and depth:
                if t.startswith("/*", i):
                    depth += 1
                    i += 2
                elif t.startswith("*/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            out.append(" ")
            continue
        tag = _dollar_tag(t, i)
        if tag:
            end = t.find(tag, i + len(tag))
            end = n if end < 0 else end + len(tag)
            out.append(t[i:end])
            i = end
            continue
        out.append(c)
        i += 1
    return "".join(out)


_DOLLAR_RE = re.compile(r"\$(?:[A-Za-z_][A-Za-z0-9_]*)?\$")


def _dollar_tag(t: str, i: int):
    """Return the dollar-quote tag starting at i ($$ or $body$), else None."""
    if t[i] != "$":
        return None
    m = _DOLLAR_RE.match(t, i)
    return m.group(0) if m else None


def norm_sql(t: str) -> str:
    """Exercise .sql normalization: drop comments, collapse whitespace."""
    return collapse_ws(strip_sql_comments(t))


def norm_cs(t: str) -> str:
    """Exercise .cs normalization: collapse whitespace only.

    Comment-stripping is unsafe here: C# raw string literals carry SQL whose
    -- and /* are content, not comments.
    """
    return collapse_ws(t)


def norm_stmt(t: str) -> str:
    """Schema statement normalization: drop lumina. qualification, collapse, tighten."""
    t = re.sub(r"\blumina\.", "", t)
    t = collapse_ws(t)
    t = re.sub(r"\s*([(),;])\s*", r"\1", t)
    return t


def split_sql(text: str) -> list[str]:
    """Split into statements on top-level ';', respecting '..', "..", $tag$..$tag$,
    -- line comments and /* */ block comments.

    Comments are replaced by whitespace, so the returned statements are already
    comment-free. Migration 060-ch13 has PL/pgSQL $$ bodies whose internal
    semicolons must not split.
    """
    stmts: list[str] = []
    buf: list[str] = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c in "'\"":
            q = c
            buf.append(c)
            i += 1
            while i < n:
                if text[i] == q:
                    if i + 1 < n and text[i + 1] == q:
                        buf.append(q)
                        buf.append(q)
                        i += 2
                        continue
                    buf.append(q)
                    i += 1
                    break
                buf.append(text[i])
                i += 1
            continue
        if text.startswith("--", i):
            j = text.find("\n", i)
            i = n if j < 0 else j
            buf.append(" ")
            continue
        if text.startswith("/*", i):
            depth, i = 1, i + 2
            while i < n and depth:
                if text.startswith("/*", i):
                    depth += 1
                    i += 2
                elif text.startswith("*/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            buf.append(" ")
            continue
        tag = _dollar_tag(text, i)
        if tag:
            end = text.find(tag, i + len(tag))
            end = n if end < 0 else end + len(tag)
            buf.append(text[i:end])
            i = end
            continue
        if c == ";":
            stmts.append("".join(buf))
            buf = []
            i += 1
            continue
        buf.append(c)
        i += 1
    stmts.append("".join(buf))
    return [s.strip() for s in stmts if s.strip()]


def read(path: Path) -> str:
    return norm_text(path.read_text(encoding="utf-8-sig"))


def fingerprint(*parts: str) -> str:
    h = hashlib.sha256()
    for p in parts:
        h.update(p.encode("utf-8", "replace"))
        h.update(b"\x00")
    return h.hexdigest()[:16]


# --------------------------------------------------------------------------
# Findings
# --------------------------------------------------------------------------

class Finding:
    __slots__ = ("category", "key", "state", "book_ref", "repo_file", "note",
                 "chapter", "fp", "detail", "orig_state")

    def __init__(self, category, key, state, book_ref, repo_file, note,
                 chapter=None, fp="", detail=""):
        self.category = category
        self.key = key
        self.state = state
        self.orig_state = state          # survives an ACCEPTED downgrade
        self.book_ref = book_ref
        self.repo_file = repo_file
        self.note = note
        self.chapter = chapter
        self.fp = fp
        self.detail = detail

    @property
    def baseline_key(self) -> str:
        return f"{self.category}:{self.key}"


# --------------------------------------------------------------------------
# Book extraction
# --------------------------------------------------------------------------

_EXTRACT_CACHE: dict[str, dict] = {}


def extract(unit_render_js: Path) -> dict:
    """Run extract_blocks.js on one render.js and return its JSON."""
    key = str(unit_render_js)
    if key in _EXTRACT_CACHE:
        return _EXTRACT_CACHE[key]
    if not EXTRACTOR.exists():
        raise ToolError(f"extractor not found: {EXTRACTOR}")
    if not unit_render_js.exists():
        raise ToolError(f"render.js not found: {unit_render_js}")
    node = shutil.which("node")
    if not node:
        raise ToolError("node is not on PATH; extract_blocks.js cannot run")
    proc = subprocess.run(
        [node, str(EXTRACTOR), str(unit_render_js)],
        capture_output=True, cwd=str(BOOK / "_shared"),
    )
    if proc.returncode != 0:
        err = proc.stderr.decode("utf-8", "replace").strip()
        raise ToolError(f"extract_blocks.js failed on {unit_render_js}:\n{err}")
    try:
        data = json.loads(proc.stdout.decode("utf-8", "replace"))
    except json.JSONDecodeError as exc:
        raise ToolError(f"extract_blocks.js emitted non-JSON for {unit_render_js}: {exc}")
    lossy = data.get("lossyBlocks") or []
    if lossy:
        raise ToolError(
            f"{unit_render_js}: blocks {lossy} came back lossy - the extractor could "
            f"not recover their printed text, so a comparison would be meaningless")
    _EXTRACT_CACHE[key] = data
    return data


def chapter_unit(n: int) -> Path:
    return BOOK / "chapters" / f"Ch{n:02d}" / "render.js"


# --------------------------------------------------------------------------
# Category: csharp
# --------------------------------------------------------------------------

def _cs_sources() -> dict[str, str]:
    """Every non-generated .cs under src/, normalized, keyed by POSIX rel path."""
    out = {}
    for p in sorted((CS / "src").rglob("*.cs")):
        rel = p.relative_to(CS).as_posix()
        if "/obj/" in rel or "/bin/" in rel:
            continue
        out[rel] = read(p)
    return out


def check_csharp(mapping, chapters, suggest) -> list[Finding]:
    cmap = mapping.get("csharp", {})
    notes = mapping.get("csharpNotes", {})
    sources = _cs_sources()
    collapsed = {k: collapse_ws(v) for k, v in sources.items()}
    findings: list[Finding] = []

    for ch in CSHARP_CHAPTERS:
        if chapters and ch not in chapters:
            continue
        data = extract(chapter_unit(ch))
        for b in data["blocks"]:
            if b["kind"] != "code":
                continue
            cap = b["captionId"] or b["id"]
            parts = b["parts"] or 1
            part = b["part"] or 1
            key = cap if parts == 1 else f"{cap}#{part}"
            book_ref = f"Ch{ch} {cap} (render.js:{b['line']})"
            text = norm_text(b["text"])
            fp = fingerprint(text)

            if cap is None or cap not in cmap:
                findings.append(Finding(
                    "csharp", key, "UNMAPPED", book_ref, "-",
                    "not in book-repo-map.json csharp table", ch, fp,
                    _suggest_cs(text, sources, collapsed) if suggest else ""))
                continue

            target = cmap[cap]
            if target is None:
                findings.append(Finding(
                    "csharp", key, "COMPOSITE", book_ref, "-",
                    notes.get(cap, "documented teaching composite; no source file"),
                    ch, fp))
                continue

            if isinstance(target, list):
                if len(target) != parts:
                    findings.append(Finding(
                        "csharp", key, "ERROR", book_ref, ", ".join(target),
                        f"map lists {len(target)} paths but the listing prints "
                        f"{parts} parts", ch, fp))
                    continue
                rel = target[part - 1]
            else:
                rel = target

            if rel not in sources:
                findings.append(Finding(
                    "csharp", key, "MISSING", book_ref, rel,
                    "mapped .cs file does not exist", ch, fp))
                continue

            if text and text in sources[rel]:
                findings.append(Finding("csharp", key, "MATCH", book_ref, rel,
                                        "", ch, fp))
            elif collapse_ws(text) and collapse_ws(text) in collapsed[rel]:
                findings.append(Finding(
                    "csharp", key, "DIFFERS (whitespace only)", book_ref, rel,
                    "same tokens, different spacing/indentation", ch, fp,
                    _suggest_cs(text, sources, collapsed) if suggest else ""))
            else:
                findings.append(Finding(
                    "csharp", key, "DIFFERS", book_ref, rel,
                    "printed text is not a substring of the mapped file", ch, fp,
                    _suggest_cs(text, sources, collapsed) if suggest else ""))
    return findings


def _suggest_cs(text, sources, collapsed) -> str:
    t, tc = norm_text(text), collapse_ws(text)
    exact = [k for k, v in sources.items() if t and t in v]
    loose = [k for k, v in collapsed.items() if tc and tc in v and k not in exact]
    lines = []
    if exact:
        lines.append("      contains it exactly:      " + ", ".join(exact))
    if loose:
        lines.append("      contains it (ws-collapsed): " + ", ".join(loose))
    if not lines:
        lines.append("      no .cs file under src/ contains this block")
    return "\n".join(lines)


# --------------------------------------------------------------------------
# Category: exercise
# --------------------------------------------------------------------------

TIERS = {"1": "basic", "2": "intermediate", "3": "challenge"}
EX_RE = re.compile(r"^Exercise (\d+)\.(\d)")


def check_exercise(chapters, verbose) -> list[Finding]:
    data = extract(BOOK / "appendices" / "D" / "render.js")
    findings: list[Finding] = []

    # Every exercise heading, in order, even if it prints no code.
    order: list[tuple[str, int, str, str]] = []   # (key, chapter, tier, heading)
    seen = set()
    for h in data["headings"]:
        m = EX_RE.match(h["text"])
        if not m:
            continue
        key = f"{int(m.group(1))}.{m.group(2)}"
        if key in seen:
            continue
        seen.add(key)
        order.append((key, int(m.group(1)), TIERS.get(m.group(2), "?"), h["text"]))

    # Blocks grouped by their owning heading.
    by_heading: dict[str, list[dict]] = {}
    for b in data["blocks"]:
        if b["kind"] not in ("sql", "code"):     # psql is output, not a solution
            continue
        by_heading.setdefault(b["heading"] or "", []).append(b)

    for key, ch, tier, heading in order:
        if chapters and ch not in chapters:
            continue
        blocks = by_heading.get(heading, [])
        ext = "cs" if any(b["kind"] == "code" for b in blocks) else "sql"
        rel = f"exercises/ch{ch:02d}/solutions/{tier}.{ext}"
        repo = CS / rel
        if not repo.exists():
            alt = "sql" if ext == "cs" else "cs"
            cand = CS / f"exercises/ch{ch:02d}/solutions/{tier}.{alt}"
            if cand.exists():
                rel, repo, ext = cand.relative_to(CS).as_posix(), cand, alt

        book_ref = f"AppD {heading}"
        if not blocks:
            findings.append(Finding(
                "exercise", key, "BOOK-PRINTS-NOTHING", book_ref,
                rel if repo.exists() else "-",
                "no sql/code block under this heading; the repo solution is "
                "unverifiable from the printed page", ch, fingerprint("")))
            continue
        if not repo.exists():
            findings.append(Finding(
                "exercise", key, "MISSING", book_ref, rel,
                "no solution file in the companion repo", ch,
                fingerprint("\n".join(norm_text(b["text"]) for b in blocks))))
            continue

        book_raw = "\n\n".join(norm_text(b["text"]) for b in blocks)
        repo_raw = read(repo)
        normalize = norm_cs if ext == "cs" else norm_sql
        bn, rn = normalize(book_raw), normalize(repo_raw)
        fp = fingerprint(bn, rn)

        if bn and bn in rn:
            findings.append(Finding("exercise", key, "MATCH", book_ref, rel,
                                    "", ch, fp))
        else:
            detail = _diff_window(book_raw, repo_raw, ext) if verbose else ""
            findings.append(Finding(
                "exercise", key, "DIFFERS", book_ref, rel,
                "printed solution is not contained in the repo solution",
                ch, fp, detail))
    return findings


def _diff_lines(text: str, ext: str) -> list[str]:
    """Normalized, non-empty lines - readable stand-ins for the flattened form."""
    body = text if ext == "cs" else strip_sql_comments(text)
    out = []
    for line in norm_text(body).split("\n"):
        s = re.sub(r"\s+", " ", line).strip()
        if s:
            out.append(s)
    return out


def _diff_window(book_raw: str, repo_raw: str, ext: str) -> str:
    a = _diff_lines(book_raw, ext)
    b = _diff_lines(repo_raw, ext)
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    blocks = [m for m in sm.get_matching_blocks() if m.size]
    if blocks:
        lo = max(0, min(m.b for m in blocks) - 2)
        hi = min(len(b), max(m.b + m.size for m in blocks) + 2)
    else:
        lo, hi = 0, len(b)
    window = b[lo:hi]
    diff = difflib.unified_diff(a, window, fromfile="book (Appendix D)",
                                tofile=f"repo lines {lo + 1}-{hi}", lineterm="")
    lines = list(diff)
    if len(lines) > 60:
        lines = lines[:60] + [f"... ({len(lines) - 60} more diff lines)"]
    return "\n".join("      " + l for l in lines)


# --------------------------------------------------------------------------
# Category: schema
# --------------------------------------------------------------------------

MIGRATION_RE = re.compile(r"^(\d{3})-ch(\d{2})-", re.IGNORECASE)


def _book_statement_pool(ch: int) -> tuple[set[str], dict[str, str]]:
    """Normalized statements from that chapter's non-skip generated .sql files."""
    manifest = BOOK / "chapters" / f"Ch{ch:02d}" / f"Ch{ch:02d}.listings.json"
    skip_ids = set()
    if manifest.exists():
        for entry in json.loads(manifest.read_text(encoding="utf-8-sig")):
            if entry.get("run") == "skip":
                skip_ids.add(entry.get("id"))
    pool: set[str] = set()
    origin: dict[str, str] = {}
    sqldir = CS / "sql" / f"ch{ch:02d}"
    if not sqldir.is_dir():
        return pool, origin
    for p in sorted(sqldir.glob("*.sql")):
        lid = "-".join(p.stem.split("-")[:2])
        if lid in skip_ids:
            continue
        for stmt in split_sql(read(p)):
            key = norm_stmt(stmt)
            if key:
                pool.add(key)
                origin.setdefault(key, f"{lid} ({p.name})")
    return pool, origin


def check_schema(mapping, chapters, verbose) -> list[Finding]:
    findings: list[Finding] = []
    targets: list[tuple[Path, int]] = []

    for rel, ch in (mapping.get("schema") or {}).items():
        p = CS / rel
        targets.append((p, int(ch)))
    for p in sorted((CS / "schema" / "migrations").glob("*.sql")):
        m = MIGRATION_RE.match(p.name)
        if not m:
            findings.append(Finding(
                "schema", p.relative_to(CS).as_posix(), "ERROR",
                "-", p.relative_to(CS).as_posix(),
                "filename does not match 0NN-chMM-*.sql, chapter undeterminable"))
            continue
        targets.append((p, int(m.group(2))))

    for path, ch in targets:
        rel = path.relative_to(CS).as_posix() if path.is_relative_to(CS) else str(path)
        if chapters and ch not in chapters:
            continue
        if not path.exists():
            findings.append(Finding("schema", rel, "MISSING", f"Ch{ch}", rel,
                                    "declared in the map but absent", ch,
                                    fingerprint(rel)))
            continue
        pool, origin = _book_statement_pool(ch)
        repo_stmts = split_sql(read(path))
        repo_norm = [norm_stmt(s) for s in repo_stmts]
        unmatched = [(orig, key) for orig, key in zip(repo_stmts, repo_norm)
                     if key and key not in pool]
        book_only = sorted(pool - set(k for k in repo_norm if k))
        fp = fingerprint("\n".join(sorted(k for _, k in unmatched)))

        if not pool:
            findings.append(Finding(
                "schema", rel, "ERROR", f"Ch{ch}", rel,
                f"no generated sql/ch{ch:02d}/*.sql to compare against", ch, fp))
            continue

        if unmatched:
            detail = ""
            if verbose:
                out = []
                for orig, key in unmatched[:8]:
                    head = collapse_ws(orig)[:150]
                    out.append(f"      - {head}")
                    near = difflib.get_close_matches(key, pool, n=1, cutoff=0.75)
                    if near:
                        out.append(f"        closest book statement "
                                   f"[{origin.get(near[0], '?')}]: {near[0][:150]}")
                if len(unmatched) > 8:
                    out.append(f"      ... and {len(unmatched) - 8} more")
                detail = "\n".join(out)
            findings.append(Finding(
                "schema", rel, "DIFFERS", f"Ch{ch} listings", rel,
                f"{len(unmatched)}/{len(repo_stmts)} migration statements have no "
                f"counterpart in the chapter's listings", ch, fp, detail))
        else:
            note = f"{len(repo_stmts)}/{len(repo_stmts)} statements replay Ch{ch}"
            findings.append(Finding("schema", rel, "MATCH", f"Ch{ch} listings",
                                    rel, note, ch, fp))

        if book_only:
            findings.append(Finding(
                "schema", rel + " [book-only]", "INFO", f"Ch{ch} listings", rel,
                f"{len(book_only)} statement(s) printed in Ch{ch} but not carried "
                f"into the migration (teaching detours are legitimate)", ch,
                fingerprint("\n".join(book_only)),
                "\n".join("      + " + s[:150] for s in book_only[:10]) if verbose else ""))
    return findings


# --------------------------------------------------------------------------
# Category: manifest
# --------------------------------------------------------------------------

def check_manifest(chapters) -> list[Finding]:
    findings: list[Finding] = []
    for ch in range(1, 24):
        if chapters and ch not in chapters:
            continue
        name = f"Ch{ch:02d}.listings.json"
        src = BOOK / "chapters" / f"Ch{ch:02d}" / name
        dst = CS / "sql" / "manifests" / name
        rel = f"sql/manifests/{name}"
        book_ref = f"Book/chapters/Ch{ch:02d}/{name}"
        if not src.exists():
            findings.append(Finding("manifest", f"Ch{ch:02d}", "ERROR", book_ref,
                                    rel, "generated manifest missing from the book",
                                    ch, fingerprint(name)))
            continue
        if not dst.exists():
            findings.append(Finding("manifest", f"Ch{ch:02d}", "MISSING", book_ref,
                                    rel, "not copied into the companion repo", ch,
                                    fingerprint(src.read_bytes().hex()[:64])))
            continue
        a, b = src.read_bytes(), dst.read_bytes()
        fp = fingerprint(hashlib.sha256(a).hexdigest(), hashlib.sha256(b).hexdigest())
        if a == b:
            findings.append(Finding("manifest", f"Ch{ch:02d}", "MATCH", book_ref,
                                    rel, "", ch, fp))
        elif a.replace(b"\r\n", b"\n") == b.replace(b"\r\n", b"\n"):
            findings.append(Finding("manifest", f"Ch{ch:02d}", "DIFFERS (EOL)",
                                    book_ref, rel,
                                    "identical apart from line endings", ch, fp))
        else:
            ja = json.loads(a.decode("utf-8-sig"))
            jb = json.loads(b.decode("utf-8-sig"))
            note = ("same JSON, different formatting" if ja == jb
                    else f"content differs ({len(ja)} vs {len(jb)} entries)")
            findings.append(Finding("manifest", f"Ch{ch:02d}", "DIFFERS", book_ref,
                                    rel, note, ch, fp))
    return findings


# --------------------------------------------------------------------------
# Category: config
# --------------------------------------------------------------------------

def check_config(mapping, chapters, verbose) -> list[Finding]:
    cfg = mapping.get("config") or {}
    findings: list[Finding] = []
    if chapters and CONFIG_CHAPTER not in chapters:
        return findings

    # -- 01-01: abridged docker-compose.yml, key lines only ------------------
    spec = cfg.get("01-01")
    if spec:
        rel = spec["file"]
        repo = CS / rel
        data = extract(chapter_unit(1))
        block = next((b for b in data["blocks"]
                      if (b["captionId"] or b["id"]) == "01-01"), None)
        if block is None:
            findings.append(Finding("config", "01-01", "ERROR", "Ch01 01-01", rel,
                                    "listing 01-01 not found in Ch01/render.js",
                                    CONFIG_CHAPTER, fingerprint("01-01")))
        elif not repo.exists():
            findings.append(Finding("config", "01-01", "MISSING", "Ch01 01-01", rel,
                                    "compose file absent", CONFIG_CHAPTER,
                                    fingerprint("01-01")))
        else:
            pats = [re.compile(p) for p in spec["keyPatterns"]]
            repo_lines = {l.strip() for l in read(repo).split("\n")}
            key_lines = [l.strip() for l in norm_text(block["text"]).split("\n")
                         if any(p.search(l) for p in pats)]
            absent = [l for l in key_lines if l not in repo_lines]
            fp = fingerprint("\n".join(key_lines), "\n".join(sorted(absent)))
            if not key_lines:
                findings.append(Finding("config", "01-01", "ERROR", "Ch01 01-01",
                                        rel, "keyPatterns matched no printed line",
                                        CONFIG_CHAPTER, fp))
            elif absent:
                findings.append(Finding(
                    "config", "01-01", "DIFFERS", "Ch01 01-01", rel,
                    f"{len(absent)}/{len(key_lines)} key line(s) printed in the "
                    f"book are not in the compose file", CONFIG_CHAPTER, fp,
                    "\n".join("      - " + l for l in absent) if verbose else ""))
            else:
                findings.append(Finding(
                    "config", "01-01", "MATCH", "Ch01 01-01", rel,
                    f"{len(key_lines)} key line(s) present "
                    f"(abridged listing: only image:/container_name: compared)",
                    CONFIG_CHAPTER, fp))

    # -- composeVsConf: every -c key=value has an uncommented key = value -----
    spec = cfg.get("composeVsConf")
    if spec:
        compose = CS / spec["compose"]
        conf = CS / spec["conf"]
        rel = spec["conf"]
        if not compose.exists() or not conf.exists():
            findings.append(Finding("config", "composeVsConf", "MISSING",
                                    spec["compose"], rel, "file absent",
                                    CONFIG_CHAPTER, fingerprint("composeVsConf")))
        else:
            flags = re.findall(r"-c\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(\S+)",
                               read(compose))
            conf_text = read(conf)
            missing = []
            for key, val in flags:
                pat = re.compile(r"^\s*" + re.escape(key) + r"\s*=\s*'?" +
                                 re.escape(val) + r"'?\s*(?:#.*)?$", re.MULTILINE)
                if not pat.search(conf_text):
                    missing.append(f"{key}={val}")
            fp = fingerprint(",".join(f"{k}={v}" for k, v in flags),
                             ",".join(missing))
            if missing:
                findings.append(Finding(
                    "config", "composeVsConf", "DIFFERS", spec["compose"], rel,
                    f"{len(missing)}/{len(flags)} compose -c setting(s) have no "
                    f"uncommented counterpart: " + ", ".join(missing),
                    CONFIG_CHAPTER, fp,
                    "\n".join("      - " + m for m in missing) if verbose else ""))
            else:
                findings.append(Finding(
                    "config", "composeVsConf", "MATCH", spec["compose"], rel,
                    f"all {len(flags)} compose -c settings documented",
                    CONFIG_CHAPTER, fp))
    return findings


# --------------------------------------------------------------------------
# Baseline
# --------------------------------------------------------------------------

def load_baseline() -> dict:
    if not BASELINE_PATH.exists():
        return {}
    try:
        data = json.loads(BASELINE_PATH.read_text(encoding="utf-8-sig"))
    except json.JSONDecodeError as exc:
        raise ToolError(f"{BASELINE_PATH.name} is not valid JSON: {exc}")
    return data.get("findings", data)


def apply_baseline(findings: list[Finding], baseline: dict,
                   categories, chapters) -> list[str]:
    """Downgrade baselined findings to ACCEPTED; return stale-key warnings.

    Stale keys are only reported for categories this run actually covered, and
    only when no --chapter filter is narrowing the sweep - otherwise every
    filtered run would warn about keys it never had a chance to produce.
    """
    if not baseline:
        return []
    present = set()
    for f in findings:
        bk = f.baseline_key
        present.add(bk)
        entry = baseline.get(bk)
        if not entry or f.state in ("MATCH",):
            continue
        if entry.get("fingerprint") == f.fp and entry.get("state") == f.state:
            f.note = (f"accepted baseline ({entry.get('state')})"
                      + (f" - {f.note}" if f.note else ""))
            f.state = "ACCEPTED"       # orig_state keeps the real verdict
    if chapters:
        return []
    return [k for k in sorted(baseline)
            if k not in present and k.split(":", 1)[0] in set(categories)]


def write_baseline(findings: list[Finding]) -> int:
    entries = {}
    for f in findings:
        # orig_state, not state: a finding already downgraded to ACCEPTED by the
        # baseline being rewritten must be carried forward, not silently dropped.
        state = f.orig_state
        if state == "MATCH":
            continue
        entries[f.baseline_key] = {
            "state": state,
            "fingerprint": f.fp,
            "note": f.note,
        }
    payload = {
        "_README": "Written by verify-book-vs-repo.py --baseline. A finding whose "
                   "key AND fingerprint still match is reported ACCEPTED; a changed "
                   "fingerprint reports DIFFERS again.",
        "findings": entries,
    }
    BASELINE_PATH.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return len(entries)


# --------------------------------------------------------------------------
# Reporting
# --------------------------------------------------------------------------

def render(findings: list[Finding], category: str, verbose: bool) -> None:
    rows = [f for f in findings if f.category == category]
    if not rows:
        return
    shown = rows if verbose else [f for f in rows if f.state != "MATCH"]
    print()
    print(f"== {category} " + "=" * max(0, 74 - len(category)))
    if shown:
        w_state = max(5, max(len(f.state) for f in shown))
        w_key = max(3, min(34, max(len(f.key) for f in shown)))
        w_book = max(8, min(46, max(len(f.book_ref) for f in shown)))
        w_repo = max(9, min(46, max(len(f.repo_file) for f in shown)))
        print(f"{'STATE':<{w_state}} | {'KEY':<{w_key}} | {'BOOK REF':<{w_book}} "
              f"| {'REPO FILE':<{w_repo}} | NOTE")
        print("-" * (w_state + w_key + w_book + w_repo + 14))
        for f in shown:
            print(f"{f.state:<{w_state}} | {f.key[:w_key]:<{w_key}} | "
                  f"{f.book_ref[:w_book]:<{w_book}} | "
                  f"{f.repo_file[:w_repo]:<{w_repo}} | {f.note}")
            if f.detail:
                print(f.detail)
    else:
        print("(all MATCH; re-run with --verbose to list them)")

    counts: dict[str, int] = {}
    for f in rows:
        counts[f.state] = counts.get(f.state, 0) + 1
    summary = "  ".join(f"{k}={v}" for k, v in sorted(counts.items()))
    print(f"-- {category} summary: {len(rows)} finding(s):  {summary}")


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main(argv=None) -> int:
    ap = argparse.ArgumentParser(
        description="Check the hand-maintained seams between the book and "
                    "CodeSample for drift.")
    ap.add_argument("--chapter", type=int, action="append", metavar="N",
                    help="restrict to chapter N (repeatable)")
    ap.add_argument("--category", action="append", choices=CATEGORIES,
                    help="restrict to one category (repeatable)")
    ap.add_argument("--verbose", action="store_true",
                    help="list MATCH rows too, and print diffs/details")
    ap.add_argument("--suggest", action="store_true",
                    help="for unmapped/differing C# blocks, name the .cs files "
                         "that do contain them")
    ap.add_argument("--baseline", action="store_true",
                    help="write tools/book-repo-baseline.json from this run's "
                         "non-MATCH findings")
    args = ap.parse_args(argv)

    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

    chapters = set(args.chapter or [])
    categories = args.category or list(CATEGORIES)

    try:
        if not MAP_PATH.exists():
            raise ToolError(f"missing {MAP_PATH}")
        mapping = json.loads(MAP_PATH.read_text(encoding="utf-8-sig"))

        findings: list[Finding] = []
        if "csharp" in categories:
            findings += check_csharp(mapping, chapters, args.suggest)
        if "exercise" in categories:
            findings += check_exercise(chapters, args.verbose)
        if "schema" in categories:
            findings += check_schema(mapping, chapters, args.verbose)
        if "manifest" in categories:
            findings += check_manifest(chapters)
        if "config" in categories:
            findings += check_config(mapping, chapters, args.verbose)

        baseline = load_baseline()
        stale = apply_baseline(findings, baseline, categories, chapters)
    except ToolError as exc:
        print(f"verify-book-vs-repo: TOOL ERROR: {exc}", file=sys.stderr)
        return 2

    print("book-vs-repo drift check")
    print(f"  book       {BOOK}")
    print(f"  repo       {CS}")
    print(f"  map        {MAP_PATH.name}")
    print(f"  baseline   {BASELINE_PATH.name if baseline else '(none)'}")
    if chapters:
        print(f"  chapters   {sorted(chapters)}")
    if args.category:
        print(f"  categories {categories}")

    for cat in CATEGORIES:
        if cat in categories:
            render(findings, cat, args.verbose)

    for key in stale:
        print(f"\nWARNING: baseline key no longer occurs: {key}")

    hard = [f for f in findings if f.state in HARD_STATES]
    fail = [f for f in findings if f.state in FAIL_STATES]

    print()
    print("=" * 80)
    total = {}
    for f in findings:
        total[f.state] = total.get(f.state, 0) + 1
    print("OVERALL: " + "  ".join(f"{k}={v}" for k, v in sorted(total.items())))

    if args.baseline:
        n = write_baseline(findings)
        print(f"baseline written: {BASELINE_PATH} ({n} finding(s))")

    if hard:
        print(f"EXIT 2: {len(hard)} unmapped/tool-level finding(s)")
        return 2
    if fail:
        print(f"EXIT 1: {len(fail)} unaccepted DIFFERS/MISSING finding(s)")
        return 1
    print("EXIT 0: clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
