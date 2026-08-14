# pgpass-env.ps1 — make the user's pgpass.conf visible to tools that can't read it.
#
# Windows Store Python runs in an MSIX app container that VIRTUALIZES AppData,
# so libpq inside it cannot open %APPDATA%\postgresql\pgpass.conf even via an
# explicit PGPASSFILE. PowerShell is not virtualized: dot-source this script to
# resolve the matching pgpass entry and expose it as $env:PGPASSWORD for child
# processes — libpq's sanctioned environment mechanism. The password is never
# written to disk or printed.
#
# No-op when PGPASSWORD is already set or no pgpass entry matches.

if (-not $env:PGPASSWORD) {
    $pgpass = Join-Path $env:APPDATA 'postgresql\pgpass.conf'
    if (Test-Path $pgpass) {
        $wantHost = if ($env:PGHOST) { $env:PGHOST } else { 'localhost' }
        $wantUser = if ($env:PGUSER) { $env:PGUSER } else { 'postgres' }
        $wantPort = if ($env:PGPORT) { $env:PGPORT } else { '5432' }
        foreach ($line in Get-Content $pgpass) {
            if ($line -match '^\s*#' -or -not $line.Trim()) { continue }
            $f = $line -split ':', 5
            if ($f.Count -lt 5) { continue }
            $hostOk = ($f[0] -eq '*' -or $f[0] -eq $wantHost)
            $portOk = ($f[1] -eq '*' -or $f[1] -eq $wantPort)
            $userOk = ($f[3] -eq '*' -or $f[3] -eq $wantUser)
            if ($hostOk -and $portOk -and $userOk) {
                $env:PGPASSWORD = $f[4]
                break
            }
        }
    }
}
