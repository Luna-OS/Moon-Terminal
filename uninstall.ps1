#Requires -Version 5.1
<#
    .SYNOPSIS
        Removes everything Moon-Terminal's install.ps1 added.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $repoRoot 'windows-terminal\Common.ps1')

function Write-Step { param([string]$Message) Write-Host "==> $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "    $Message" -ForegroundColor Green }
function Write-Warn2 { param([string]$Message) Write-Host "    $Message" -ForegroundColor Yellow }

# 1. Remove the fragment (Moon Dark scheme + Claude Code profile)
Write-Step "Removing the Moon Dark scheme + Claude Code profile"
$fragmentDestDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\Moon-Terminal'
if (Test-Path $fragmentDestDir) {
    Remove-Item -Path $fragmentDestDir -Recurse -Force
    Write-Ok "Removed $fragmentDestDir"
}
else {
    Write-Ok "Nothing to remove (fragment not installed)."
}

# 2. Remove the keybindings Moon-Terminal added
Write-Step "Removing Claude Code keybindings from settings.json"
$settingsPath = Get-WindowsTerminalSettingsPath
if (-not $settingsPath) {
    Write-Warn2 "Could not find settings.json. Skipping."
}
else {
    try {
        $ourKeys = (Get-Content -Path (Join-Path $repoRoot 'windows-terminal\keybindings.json') -Raw | ConvertFrom-Json) | ForEach-Object { $_.keys }

        $raw = Get-Content -Path $settingsPath -Raw
        $config = ConvertFrom-Jsonc -Raw $raw

        if ($config.PSObject.Properties['keybindings'] -and $config.keybindings) {
            $before = @($config.keybindings).Count
            $filtered = @($config.keybindings | Where-Object { $ourKeys -notcontains $_.keys })
            $removed = $before - $filtered.Count

            if ($removed -gt 0) {
                $backupPath = Backup-File -Path $settingsPath
                Write-Ok "Backed up settings.json to $backupPath"
                $config.keybindings = $filtered
                ($config | ConvertTo-Json -Depth 32) | Set-Content -Path $settingsPath -Encoding utf8
                Write-Ok "Removed $removed Moon-Terminal keybinding(s)."
            }
            else {
                Write-Ok "No Moon-Terminal keybindings found."
            }
        }
        else {
            Write-Ok "No keybindings section found."
        }
    }
    catch {
        Write-Warn2 "Could not safely edit settings.json ($($_.Exception.Message)). Remove the bindings for ctrl+shift+m/k/z manually if present."
    }
}

# 3. Remove the PowerShell profile block
Write-Step "Removing Claude Code helpers from your PowerShell profile"
$profilePath = $PROFILE.CurrentUserCurrentHost
if (Test-Path $profilePath) {
    $marker = '# >>> Moon-Terminal: Claude Code helpers >>>'
    $endMarker = '# <<< Moon-Terminal: Claude Code helpers <<<'
    $existing = Get-Content -Path $profilePath -Raw
    if ($existing -match [regex]::Escape($marker)) {
        $pattern = "(?s)\r?\n?$([regex]::Escape($marker)).*?$([regex]::Escape($endMarker))\r?\n?"
        $updated = [regex]::Replace($existing, $pattern, "`n")
        Set-Content -Path $profilePath -Value $updated.Trim() -Encoding utf8
        Write-Ok "Removed the Moon-Terminal block from $profilePath"
    }
    else {
        Write-Ok "No Moon-Terminal block found in your profile."
    }
}
else {
    Write-Ok "No PowerShell profile file found."
}

Write-Host ""
Write-Ok "Moon-Terminal uninstalled. Restart Windows Terminal and PowerShell."
