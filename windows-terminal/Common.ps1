# Shared helpers for install.ps1 / uninstall.ps1.

function Get-WindowsTerminalSettingsPath {
    <#
        Returns the path to the user's Windows Terminal settings.json, checking both the
        packaged (Microsoft Store) and unpackaged (winget/scoop/portable) install locations.
    #>
    $packaged = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    $unpackaged = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json'

    $candidates = @($packaged, $unpackaged) | Where-Object { Test-Path $_ }

    if (-not $candidates) {
        return $null
    }
    if ($candidates.Count -eq 1) {
        return $candidates[0]
    }
    # Both present (e.g. Store + winget builds installed side by side): use whichever was touched most recently.
    return ($candidates | Sort-Object { (Get-Item $_).LastWriteTime } -Descending | Select-Object -First 1)
}

function ConvertFrom-Jsonc {
    <#
        Windows Terminal's settings.json is JSONC (allows // and /* */ comments plus trailing
        commas). This strips both, string-aware, so ConvertFrom-Json can parse the result.
    #>
    param([Parameter(Mandatory)][string]$Raw)

    $sb = New-Object System.Text.StringBuilder
    $inString = $false
    $escape = $false
    $inLineComment = $false
    $inBlockComment = $false

    for ($i = 0; $i -lt $Raw.Length; $i++) {
        $c = $Raw[$i]
        $next = if ($i + 1 -lt $Raw.Length) { $Raw[$i + 1] } else { [char]0 }

        if ($inLineComment) {
            if ($c -eq "`n") { $inLineComment = $false; [void]$sb.Append($c) }
            continue
        }
        if ($inBlockComment) {
            if ($c -eq '*' -and $next -eq '/') { $inBlockComment = $false; $i++ }
            continue
        }
        if ($inString) {
            [void]$sb.Append($c)
            if ($escape) { $escape = $false }
            elseif ($c -eq '\') { $escape = $true }
            elseif ($c -eq '"') { $inString = $false }
            continue
        }
        if ($c -eq '"') { $inString = $true; [void]$sb.Append($c); continue }
        if ($c -eq '/' -and $next -eq '/') { $inLineComment = $true; $i++; continue }
        if ($c -eq '/' -and $next -eq '*') { $inBlockComment = $true; $i++; continue }
        [void]$sb.Append($c)
    }

    $clean = $sb.ToString()
    # Trailing commas before a closing bracket/brace are legal in JSONC but not in strict JSON.
    $clean = [regex]::Replace($clean, ',(\s*[\]\}])', '$1')
    return $clean | ConvertFrom-Json
}

function Backup-File {
    param([Parameter(Mandatory)][string]$Path)
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupPath = "$Path.bak-$stamp"
    Copy-Item -Path $Path -Destination $backupPath -Force
    return $backupPath
}
