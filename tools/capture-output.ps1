<#
.SYNOPSIS
    Capture the real output of a chapter's listings, for the book to print.

.DESCRIPTION
    The book never prints hand-typed psql output: every psqlBlock with
    expect = 'match' or 'shape' is fed from files this script captures. That
    inverts the usual failure mode — it is structurally impossible for the book
    to print output the database did not produce.

    Pairing rule: a psql-output manifest entry captures the output of the
    CLOSEST PRECEDING sql entry in render order. Output goes to
    sql/chNN/.expected/<output-id>.txt, normalized by normalize.py
    (--mode from the entry's expect, --sort when the paired SQL has no ORDER BY).

.EXAMPLE
    .\capture-output.ps1 -Chapter 16
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
$expectedDir = Join-Path $sqlDir '.expected'

if (-not (Test-Path $manifestPath)) {
    throw "No manifest at $manifestPath — run 'node render.js' in Book\chapters\Ch$nn first."
}
# PS 5.1: ConvertFrom-Json returns a JSON array as ONE pipeline object; piping
# through ForEach-Object unrolls it into a real element list.
$manifest = @((Get-Content $manifestPath -Raw | ConvertFrom-Json) | ForEach-Object { $_ })

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

if (-not $SkipReset) {
    & (Join-Path $repo 'scripts\reset-to-chapter.ps1') -Chapter $Chapter
}
New-Item -ItemType Directory -Force -Path $expectedDir | Out-Null

# Replay the WHOLE chapter in manifest order — listing output depends on the
# cumulative state every earlier listing built (Ch2's \dt is meaningless unless
# the CREATE TABLE listings ran first). Capture stdout at each paired output.
$captured = 0
$lastSql = $null
foreach ($entry in $manifest) {
    if ($entry.kind -eq 'sql') {
        $lastSql = $entry
        if ($entry.run -eq 'none') { continue }

        $file = Get-ChildItem $sqlDir -Filter "$($entry.id)*.sql" | Select-Object -First 1
        if (-not $file) { throw "No generated file for $($entry.id) in $sqlDir." }
        $target = $file.FullName

        if ($entry.run -eq 'two-conn') {
            # The interleaved transcript IS the output; run-two-conn.py already
            # labels each line with its session.
            . (Join-Path $PSScriptRoot 'pgpass-env.ps1')
            $prevEap = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $raw = (& python (Join-Path $PSScriptRoot 'run-two-conn.py') $target 2>$null |
                ForEach-Object { "$_" }) -join "`n"
            $code = $LASTEXITCODE
            $ErrorActionPreference = $prevEap
            if ($code -ne 0) { throw "Two-conn replay failed at $($entry.id)." }
            $script:lastOutput = $raw
            continue
        }

        if ($entry.run -eq 'fragment') {
            $wrapped = Join-Path $env:TEMP "lumina-cap-$($entry.id).sql"
            @("BEGIN;", (Get-Content $target -Raw), "ROLLBACK;") | Set-Content $wrapped -Encoding utf8
            $target = $wrapped
        }

        # Same PS 5.1 native-stderr trap as verify-listings: a skip listing's
        # expected failure must not kill the replay.
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        # PS 5.1 wraps native stderr in ErrorRecords; rendering those through
        # Out-String adds "psql.exe : ... At line:..." decoration that is not
        # psql output. Unwrap to the raw text of each line instead.
        $raw = (& $psql -X -P footer=on -d lumina -f $target 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" }
        }) -join "`n"
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        if ($code -ne 0 -and $entry.run -ne 'skip') {
            throw "Replay failed at $($entry.id): $raw"
        }
        if ($entry.run -eq 'fragment') {
            # The BEGIN/ROLLBACK wrapper is harness scaffolding, not the reader's
            # session — its command tags must not appear in expected output.
            $lines = $raw -split "`r?`n"
            $raw = ($lines | Where-Object { $_ -notmatch '^(BEGIN|ROLLBACK)\s*$' }) -join "`n"
        }
        $script:lastOutput = $raw
        continue
    }
    if ($entry.kind -ne 'psql-output') { continue }
    if ($entry.expect -notin @('match', 'shape')) { continue }
    if (-not $lastSql) {
        Write-Warning "Output $($entry.id) has no preceding sql listing — skipped."
        continue
    }

    # Sort only unordered SELECT results. Meta-commands (\dt, \d) emit
    # deterministic psql-sorted output, and sorting \d's grid would reorder a
    # table's COLUMNS alphabetically — exactly wrong.
    $sqlFile = Get-ChildItem $sqlDir -Filter "$($lastSql.id)*.sql" | Select-Object -First 1
    $sortArgs = @()
    # Never sort a two-conn transcript (the interleave order IS the lesson) or
    # an EXPLAIN's plan tree (indentation order IS the plan).
    if ($sqlFile -and $lastSql.run -ne 'two-conn') {
        $sqlText = Get-Content $sqlFile.FullName -Raw
        if ($sqlText -match '(?i)\bSELECT\b' -and
            $sqlText -notmatch '(?i)ORDER\s+BY' -and
            $sqlText -notmatch '(?i)\bEXPLAIN\b') {
            $sortArgs = @('--sort')
        }
    }

    $outPath = Join-Path $expectedDir "$($entry.id).txt"
    # PS 5.1's -Encoding utf8 writes a BOM, which then leaks invisibly into the
    # first line of every printed psqlBlock. Write BOM-less.
    $normalized = ($script:lastOutput |
        python (Join-Path $PSScriptRoot 'normalize.py') --mode $entry.expect @sortArgs) -join "`n"
    [System.IO.File]::WriteAllText($outPath, $normalized + "`n",
        (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "[cap ] $($entry.id) <- $($lastSql.id)  ($($entry.expect)$(if ($sortArgs) { ', sorted' }))"
    $captured++
}

Write-Host ""
Write-Host "Ch$nn : captured $captured expected output(s) into $expectedDir"
