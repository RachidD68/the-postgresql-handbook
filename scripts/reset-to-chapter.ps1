<#
.SYNOPSIS
    Reset the lumina database to the exact state a given chapter expects.

.DESCRIPTION
    ENTRY-STATE SEMANTICS: -Chapter N produces the state you need to BEGIN
    chapter N, so a chapter's own DDL runs as its listings, not as pre-applied
    state. The core schema is Chapter 2's work product - it exists from
    Chapter 3 onward. Migrations apply when their chapter is STRICTLY BELOW N.
    One exception: Chapter 23's migration (pgvector + kb_article) IS pre-applied
    at N=23, because its embedded corpus cannot be a listing.

    CONNECTION: uses a psql found on this machine (or $env:PSQL) via the
    standard libpq variables (PGHOST, PGPORT, PGUSER, PGPASSWORD; defaults
    localhost:5432 as postgres). If no host psql exists, it falls back to
    running psql INSIDE the book's Docker container (lumina-db) - so a
    Docker-only reader needs nothing installed beyond Docker itself.

.PARAMETER Chapter
    Target chapter state, 1-23. Default 23 (everything).

.PARAMETER Bulk
    Force-load seed-bulk.sql even below Chapter 15 (it loads automatically at 15+).

.EXAMPLE
    .\reset-to-chapter.ps1 -Chapter 9
#>
[CmdletBinding()]
param(
    [ValidateRange(1, 23)]
    [int]$Chapter = 23,
    [switch]$Bulk
)

$ErrorActionPreference = 'Stop'

# -- Locate a way to run psql: host binary, or the book's container ----
$psql = $env:PSQL
if (-not $psql) {
    $candidates = @(
        'C:\Program Files\PostgreSQL\18\bin\psql.exe',
        (Get-Command psql -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
    )
    $psql = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}

$useDocker = $false
if (-not $psql) {
    $dockerOk = $false
    try {
        $state = docker inspect -f '{{.State.Running}}' lumina-db 2>$null
        if ("$state".Trim() -eq 'true') { $dockerOk = $true }
    } catch { }
    if ($dockerOk) {
        $useDocker = $true
    } else {
        throw ("No psql found and the lumina-db container is not running. Either " +
               "start the container (docker compose up -d), install the psql client " +
               "(Appendix A), or set the PSQL environment variable.")
    }
}

if (-not $env:PGHOST) { $env:PGHOST = 'localhost' }
if (-not $env:PGPORT) { $env:PGPORT = '5432' }
if (-not $env:PGUSER) { $env:PGUSER = 'postgres' }

$repo = Split-Path $PSScriptRoot -Parent
$schemaDir = Join-Path $repo 'schema'
$seedDir = Join-Path $repo 'seed'

function Invoke-Sql {
    <# Run one SQL command or file against a database, via host psql or the
       container. File contents are piped over stdin in container mode, so the
       file never needs to exist inside the container. #>
    param([string]$Db, [string]$Command, [string]$File)

    if ($useDocker) {
        if ($File) {
            Get-Content $File -Raw |
                docker exec -i lumina-db psql -X -q -v ON_ERROR_STOP=1 -U postgres -d $Db -f -
        } else {
            docker exec -i lumina-db psql -X -q -v ON_ERROR_STOP=1 -U postgres -d $Db -c $Command
        }
    } else {
        if ($File) { & $psql -X -q -v ON_ERROR_STOP=1 -d $Db -f $File }
        else       { & $psql -X -q -v ON_ERROR_STOP=1 -d $Db -c $Command }
    }
    if ($LASTEXITCODE -ne 0) {
        $what = if ($File) { $File } else { $Command }
        throw "psql failed (exit $LASTEXITCODE): $what"
    }
}

# -- Connectivity check ------------------------------------------------
try {
    Invoke-Sql -Db postgres -Command "SELECT 1;" | Out-Null
} catch {
    throw ("Cannot reach PostgreSQL. Docker readers: docker compose up -d. " +
           "Native readers: check the service and PGPASSWORD (or pgpass.conf). " +
           "Details: $($_.Exception.Message)")
}

$mode = if ($useDocker) { 'container (lumina-db)' } else { "host ($($env:PGHOST):$($env:PGPORT))" }
Write-Host "Resetting lumina to chapter state $Chapter via $mode ..."

# -- Ch20 leftovers: subscriptions and slots block the drops below -----
# The logical-replication demo creates a second database (lumina_replica).
# A database that still holds a subscription refuses DROP DATABASE (FORCE
# only kills sessions), and a leftover logical slot can block dropping
# lumina itself - so detach both first, tolerating absence at every step.
function Invoke-SqlTolerant {
    param([string]$Db, [string]$Command)
    try {
        if ($useDocker) {
            docker exec -i lumina-db psql -X -q -U postgres -d $Db -c $Command 2>$null | Out-Null
        } else {
            & $psql -X -q -d $Db -c $Command 2>$null | Out-Null
        }
    } catch { }
}
function Get-SqlScalarList {
    param([string]$Db, [string]$Command)
    try {
        $out = if ($useDocker) {
            docker exec -i lumina-db psql -X -q -t -A -U postgres -d $Db -c $Command 2>$null
        } else {
            & $psql -X -q -t -A -d $Db -c $Command 2>$null
        }
        return @("$out" -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    } catch { return @() }
}

# Scan the WHOLE cluster, not just lumina_replica: a mistyped demo can leave a
# subscription in any database (including lumina itself), and one we miss makes
# every later DROP DATABASE fail. Name-agnostic on both counts, so a reader's
# own experiment cleans up as reliably as the book's.
$subDbs = Get-SqlScalarList -Db postgres -Command "SELECT DISTINCT d.datname FROM pg_subscription s JOIN pg_database d ON d.oid = s.subdbid;"
foreach ($db in $subDbs) {
    foreach ($sub in (Get-SqlScalarList -Db $db -Command "SELECT subname FROM pg_subscription;")) {
        Invoke-SqlTolerant -Db $db -Command "ALTER SUBSCRIPTION $sub DISABLE;"
        Invoke-SqlTolerant -Db $db -Command "ALTER SUBSCRIPTION $sub SET (slot_name = NONE);"
        Invoke-SqlTolerant -Db $db -Command "DROP SUBSCRIPTION IF EXISTS $sub;"
    }
}
# An ACTIVE slot refuses pg_drop_replication_slot, so evict its walsender first;
# then drop every slot that remains, whatever it is called.
Invoke-SqlTolerant -Db postgres -Command "SELECT pg_terminate_backend(active_pid) FROM pg_replication_slots WHERE active_pid IS NOT NULL;"
foreach ($slot in (Get-SqlScalarList -Db postgres -Command "SELECT slot_name FROM pg_replication_slots;")) {
    Invoke-SqlTolerant -Db postgres -Command "SELECT pg_drop_replication_slot('$slot');"
    Invoke-SqlTolerant -Db lumina   -Command "SELECT pg_drop_replication_slot('$slot');"
}

# -- Drop and recreate (this script only ever drops 'lumina') ----------
Invoke-Sql -Db postgres -Command "DROP DATABASE IF EXISTS lumina WITH (FORCE);"
# Chapter 17's roles are CLUSTER-level and survive the database drop; remove
# them so State(N) is a true function of N (migration 090 or the chapter's own
# listings recreate them). Safe: the dropped database held all their grants.
Invoke-Sql -Db postgres -Command "DROP ROLE IF EXISTS lumina_app, lumina_readonly, support_agent;"
# Ch20's logical-replication demo creates a second database whose subscription
# would point at the dropped lumina; remove it for a clean State(N).
Invoke-Sql -Db postgres -Command "DROP DATABASE IF EXISTS lumina_replica WITH (FORCE);"
Invoke-Sql -Db postgres -Command "CREATE DATABASE lumina;"

# -- Pin the settings the book's output was captured under -------------
Invoke-Sql -Db postgres -Command "ALTER DATABASE lumina SET jit = off;"
Invoke-Sql -Db postgres -Command "ALTER DATABASE lumina SET work_mem = '16MB';"
Invoke-Sql -Db postgres -Command "ALTER DATABASE lumina SET random_page_cost = 1.1;"
Invoke-Sql -Db postgres -Command "ALTER DATABASE lumina SET max_parallel_workers_per_gather = 2;"
# timestamptz literals and display in the book assume UTC; pin it so a reader
# in any timezone reproduces the captured output byte-for-byte.
Invoke-Sql -Db postgres -Command "ALTER DATABASE lumina SET timezone = 'UTC';"
# Chapter 2 teaches schemas and search_path; from then on listings say `ticket`,
# not `lumina.ticket`.
Invoke-Sql -Db postgres -Command "ALTER DATABASE lumina SET search_path = lumina, public;"

# -- Extensions + core schema (entry-state semantics) ------------------
Invoke-Sql -Db lumina -File (Join-Path $schemaDir '000-extensions.sql')
if ($Chapter -ge 3) {
    Invoke-Sql -Db lumina -File (Join-Path $schemaDir '010-core-schema.sql')
}

# -- Migrations: NNN-chMM-slug.sql, applied where MM < N (23 exception) -
$migrationsDir = Join-Path $schemaDir 'migrations'
$applied = 0
if (Test-Path $migrationsDir) {
    Get-ChildItem $migrationsDir -Filter '*.sql' | Sort-Object Name | ForEach-Object {
        if ($_.Name -match '^\d{3}-ch(\d{2})-') {
            $migCh = [int]$Matches[1]
            # Migrations normally apply STRICTLY BELOW N (entry-state semantics).
            # 110 is the one exception: seed-kb.sql needs the vector column, so
            # the migration must run AT 23 rather than before it.
            if ($migCh -lt $Chapter -or ($migCh -eq 23 -and $Chapter -eq 23)) {
                Invoke-Sql -Db lumina -File $_.FullName
                $script:applied++
            }
        } else {
            throw "Migration filename does not match NNN-chMM-slug.sql: $($_.Name)"
        }
    }
}

# -- Seeds -------------------------------------------------------------
$loaded = @()
if ($Chapter -ge 3) {
    Invoke-Sql -Db lumina -File (Join-Path $seedDir 'seed-core.sql') | Out-Null
    $loaded += 'core'
}
if (($Chapter -ge 15 -or $Bulk) -and (Test-Path (Join-Path $seedDir 'seed-bulk.sql'))) {
    Invoke-Sql -Db lumina -File (Join-Path $seedDir 'seed-bulk.sql') | Out-Null
    $loaded += 'bulk'
}
if ($Chapter -ge 23 -and (Test-Path (Join-Path $seedDir 'seed-kb.sql'))) {
    Invoke-Sql -Db lumina -File (Join-Path $seedDir 'seed-kb.sql') | Out-Null
    $loaded += 'kb'
}

# -- Migrations run BEFORE seeds, so migration 040's custom_fields backfill met
# -- an empty ticket table; re-apply it now that rows exist, so State(N) matches
# -- a reader who ran Ch11's listings on seeded data. The file is written to be
# -- applied twice (IF NOT EXISTS DDL, repeat-safe UPDATEs) - see its header.
if ($Chapter -ge 12) {
    Invoke-Sql -Db lumina -File (Join-Path $schemaDir 'migrations\040-ch11-jsonb.sql') | Out-Null
}

# -- Materialized views run in migrations BEFORE seeds, so they snapshot an
# -- empty ticket table; refresh them so State(N) matches a reader who built
# -- them against live data (Ch13's mv_monthly_stats, from Chapter 14 onward).
if ($Chapter -ge 14) {
    Invoke-Sql -Db lumina -Command "REFRESH MATERIALIZED VIEW lumina.mv_monthly_stats;"
}

# -- Fresh statistics - without this, Chapter 16's plans are noise -----
Invoke-Sql -Db lumina -Command "VACUUM (ANALYZE);"

$seedNote = if ($loaded.Count) { $loaded -join ', ' } else { 'none (schema only)' }
Write-Host "Done. Chapter state $Chapter - migrations applied: $applied, seeds: $seedNote."
