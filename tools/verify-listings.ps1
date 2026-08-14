<#
.SYNOPSIS
    Execute every SQL listing of a chapter against a fresh chapter-state database.

.DESCRIPTION
    Reads Book/chapters/ChNN/ChNN.listings.json (the manifest render.js emits),
    resets the database to State(N), then runs each generated listing file:

      run = exec      self-contained; must succeed
      run = fragment  wrapped in BEGIN ... ROLLBACK so it cannot mutate state
      run = skip      intentionally invalid; must FAIL with its declared SQLSTATE
                      (a listing that is supposed to fail and quietly succeeds is
                      a book bug too)

    Exit code is non-zero unless 100% of listings behave as declared. No chapter
    is done until this is green — see CLAUDE.md.

.EXAMPLE
    .\verify-listings.ps1 -Chapter 7
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateRange(1, 23)]
    [int]$Chapter,
    [switch]$SkipReset
)

$ErrorActionPreference = 'Stop'
$nn = '{0:D2}' -f $Chapter

$repo = Split-Path $PSScriptRoot -Parent
$projectRoot = Split-Path $repo -Parent
$manifestPath = Join-Path $projectRoot "Book\chapters\Ch$nn\Ch$nn.listings.json"
$sqlDir = Join-Path $repo "sql\ch$nn"

if (-not (Test-Path $manifestPath)) {
    throw "No manifest at $manifestPath — run 'node render.js' in Book\chapters\Ch$nn first."
}
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$sqlEntries = @($manifest | Where-Object { $_.kind -eq 'sql' })
if (-not $sqlEntries.Count) {
    Write-Host "Ch$nn declares no executable listings. Nothing to verify."
    exit 0
}

# ── psql (same resolution as reset-to-chapter.ps1) ─────────────────
$psql = $env:PSQL
if (-not $psql) {
    $candidates = @(
        'C:\Program Files\PostgreSQL\18\bin\psql.exe',
        (Get-Command psql -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
    )
    $psql = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}
if (-not $psql) { throw "psql not found. Set the PSQL environment variable." }
if (-not $env:PGHOST) { $env:PGHOST = 'localhost' }
if (-not $env:PGUSER) { $env:PGUSER = 'postgres' }

# ── Reset to State(N) ──────────────────────────────────────────────
if (-not $SkipReset) {
    & (Join-Path $repo 'scripts\reset-to-chapter.ps1') -Chapter $Chapter
}

# ── Run the listings in manifest (= render) order ──────────────────
$pass = 0; $fail = 0
foreach ($entry in $sqlEntries) {
    $file = Get-ChildItem $sqlDir -Filter "$($entry.id)*.sql" | Select-Object -First 1
    if (-not $file) {
        Write-Host "[MISS] $($entry.id) — no generated file in $sqlDir (re-run node render.js)"
        $fail++
        continue
    }

    $target = $file.FullName
    $mode = if ($entry.run) { $entry.run } else { 'exec' }

    # 'none' = documented but not executed: environment-level commands the
    # harness state makes impossible or meaningless (CREATE DATABASE against
    # the database we're connected to, \c, docker invocations). Use sparingly.
    if ($mode -eq 'none') {
        Write-Host "[ -- ] $($entry.id) (documented only, not executed)"
        $pass++
        continue
    }

    if ($mode -eq 'two-conn') {
        # Two live sessions with a scripted interleave — Chapter 14's demos.
        # run-two-conn.py owns the step protocol; exit 0 means every step
        # behaved as declared (including expect-error steps).
        . (Join-Path $PSScriptRoot 'pgpass-env.ps1')
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $out = & python (Join-Path $PSScriptRoot 'run-two-conn.py') $target 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" }
        }
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        if ($code -eq 0) {
            Write-Host "[ ok ] $($entry.id) (two-conn)"
            $pass++
        } else {
            Write-Host "[FAIL] $($entry.id) (two-conn)"
            $out | Where-Object { "$_" -match 'FAIL|Error|Timeout' } | ForEach-Object { Write-Host "       $_" }
            $fail++
        }
        continue
    }

    if ($mode -eq 'fragment') {
        # Wrap so a fragment can demonstrate anything without mutating State(N).
        $wrapped = Join-Path $env:TEMP "lumina-fragment-$($entry.id).sql"
        @("BEGIN;", (Get-Content $target -Raw), "ROLLBACK;") | Set-Content $wrapped -Encoding utf8
        $target = $wrapped
    }

    # VERBOSITY=verbose puts the SQLSTATE in stderr ("ERROR:  23514: ...") so
    # skip-listings can assert they fail for the DECLARED reason, not just fail.
    # PS 5.1 wraps native stderr in ErrorRecords, which $ErrorActionPreference =
    # 'Stop' promotes to script-killing exceptions — exactly wrong for listings
    # that are SUPPOSED to fail. Relax it for the invocation only.
    # 'exec-tolerant': a mid-script error is part of the LESSON (a SAVEPOINT
    # absorbing a failure) — run without ON_ERROR_STOP, exactly as a reader's
    # interactive session behaves; the listing's final statements prove the state.
    $stopArgs = if ($mode -eq 'exec-tolerant') { @() } else { @('-v', 'ON_ERROR_STOP=1') }
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $stderr = & $psql -X -q @stopArgs -v VERBOSITY=verbose -d lumina -f $target 2>&1 |
        Where-Object { $_ -is [System.Management.Automation.ErrorRecord] -or "$_" -match 'ERROR|FATAL' }
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prevEap

    if ($mode -eq 'skip') {
        $expected = $entry.expectError
        if ($code -eq 0) {
            Write-Host "[FAIL] $($entry.id) — declared as failing but SUCCEEDED"
            $fail++
        } elseif ($expected -and -not ("$stderr" -match [regex]::Escape($expected))) {
            Write-Host "[FAIL] $($entry.id) — failed, but not with SQLSTATE $expected"
            Write-Host "       $stderr"
            $fail++
        } else {
            Write-Host "[ ok ] $($entry.id) (failed as declared$(if ($expected) { ": $expected" }))"
            $pass++
        }
    } else {
        if ($code -eq 0) {
            Write-Host "[ ok ] $($entry.id) ($mode)"
            $pass++
        } else {
            Write-Host "[FAIL] $($entry.id) ($mode) — exit $code"
            Write-Host "       $stderr"
            $fail++
        }
    }
}

Write-Host ""
Write-Host "Ch$nn listings: $pass passed, $fail failed, $($sqlEntries.Count) total."
if ($fail -gt 0) { exit 1 }
