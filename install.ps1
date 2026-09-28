#Requires -Version 5.1
<#
    .SYNOPSIS
        Installs Moon-Terminal: a Windows Terminal color scheme + profile for Claude Code,
        a few productivity keybindings, and PowerShell helper functions.

    .DESCRIPTION
        Non-destructive by design:
          - The color scheme and "Claude Code" profile are installed as a Windows Terminal
            *fragment extension*, so your settings.json is never touched for that part.
          - Keybindings are additively merged into settings.json (a timestamped backup is
            made first). Existing bindings on the same key combo are left alone.
          - PowerShell helper functions are appended to your $PROFILE inside a clearly
            marked block, so re-running this script or uninstall.ps1 is safe.

    .PARAMETER SkipKeybindings
        Don't touch Windows Terminal's settings.json at all.

    .PARAMETER SkipProfile
        Don't touch your PowerShell $PROFILE.

    .EXAMPLE
        .\install.ps1

    .EXAMPLE
        .\install.ps1 -SkipKeybindings
#>
[CmdletBinding()]
param(
    [switch]$SkipKeybindings,
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $repoRoot 'windows-terminal\Common.ps1')

function Write-Step { param([string]$Message) Write-Host "==> $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "    $Message" -ForegroundColor Green }
function Write-Warn2 { param([string]$Message) Write-Host "    $Message" -ForegroundColor Yellow }

if (-not $IsWindows -and $env:OS -ne 'Windows_NT') {
    throw "Moon-Terminal targets Windows Terminal + PowerShell and only runs on Windows."
}

# ---------------------------------------------------------------------------
# 1. Fragment: Moon Dark color scheme + Claude Code profile (no settings.json edits)
# ---------------------------------------------------------------------------
Write-Step "Installing the Moon Dark scheme + Claude Code profile (fragment extension)"

$fragmentSrc = Join-Path $repoRoot 'windows-terminal\fragment\moon-terminal.json'
$fragmentDestDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\Moon-Terminal'
New-Item -ItemType Directory -Path $fragmentDestDir -Force | Out-Null
Copy-Item -Path $fragmentSrc -Destination (Join-Path $fragmentDestDir 'moon-terminal.json') -Force
Write-Ok "Installed to $fragmentDestDir"

# ---------------------------------------------------------------------------
# 2. Keybindings: additive merge into settings.json
# ---------------------------------------------------------------------------
if (-not $SkipKeybindings) {
    Write-Step "Adding Claude Code keybindings to Windows Terminal settings.json"

    $settingsPath = Get-WindowsTerminalSettingsPath
    if (-not $settingsPath) {
        Write-Warn2 "Could not find settings.json (is Windows Terminal installed?). Skipping this step."
        Write-Warn2 "You can add the bindings manually from windows-terminal\keybindings.json."
    }
    else {
        try {
            $raw = Get-Content -Path $settingsPath -Raw
            $config = ConvertFrom-Jsonc -Raw $raw

            $newBindings = Get-Content -Path (Join-Path $repoRoot 'windows-terminal\keybindings.json') -Raw | ConvertFrom-Json

            if (-not $config.PSObject.Properties['keybindings']) {
                $config | Add-Member -MemberType NoteProperty -Name 'keybindings' -Value @()
            }
            $existingKeys = @($config.keybindings | ForEach-Object { $_.keys })

            $added = 0
            $bindingsList = [System.Collections.Generic.List[object]]::new()
            if ($config.keybindings) { $config.keybindings | ForEach-Object { $bindingsList.Add($_) } }

            foreach ($binding in $newBindings) {
                if ($existingKeys -contains $binding.keys) {
                    Write-Warn2 "Skipping '$($binding.keys)' - already bound in your settings.json."
                    continue
                }
                $entry = [ordered]@{ keys = $binding.keys; command = $binding.command }
                $bindingsList.Add([pscustomobject]$entry)
                $added++
            }

            if ($added -gt 0) {
                $config.keybindings = $bindingsList.ToArray()
                $backupPath = Backup-File -Path $settingsPath
                Write-Ok "Backed up existing settings.json to $backupPath"

                ($config | ConvertTo-Json -Depth 32) | Set-Content -Path $settingsPath -Encoding utf8
                Write-Ok "Added $added new keybinding(s): $((($newBindings | Where-Object { $existingKeys -notcontains $_.keys }) | ForEach-Object { $_.keys }) -join ', ')"
                Write-Warn2 "Note: comments in settings.json are not preserved by this merge (functionality is unaffected)."
            }
            else {
                Write-Ok "Nothing to add - all keybindings already present."
            }
        }
        catch {
            Write-Warn2 "Could not safely merge keybindings ($($_.Exception.Message)). Skipping this step."
            Write-Warn2 "You can add them manually from windows-terminal\keybindings.json."
        }
    }
}
else {
    Write-Step "Skipping keybindings (per -SkipKeybindings)"
}

# ---------------------------------------------------------------------------
# 3. PowerShell profile helpers (ccr, ccc, ccp, ccu, ccv, cchere)
# ---------------------------------------------------------------------------
if (-not $SkipProfile) {
    Write-Step "Adding Claude Code helper functions to your PowerShell profile"

    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $marker = '# >>> Moon-Terminal: Claude Code helpers >>>'
    $endMarker = '# <<< Moon-Terminal: Claude Code helpers <<<'
    $existing = Get-Content -Path $profilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $existing) { $existing = '' }

    $snippet = Get-Content -Path (Join-Path $repoRoot 'powershell\Claude-Code.profile.ps1') -Raw

    if ($existing -match [regex]::Escape($marker)) {
        $pattern = "(?s)$([regex]::Escape($marker)).*?$([regex]::Escape($endMarker))"
        $updated = [regex]::Replace($existing, $pattern, $snippet.TrimEnd())
        Set-Content -Path $profilePath -Value $updated -Encoding utf8
        Write-Ok "Updated existing Moon-Terminal block in $profilePath"
    }
    else {
        Add-Content -Path $profilePath -Value "`n$snippet" -Encoding utf8
        Write-Ok "Appended helper functions to $profilePath"
    }
    Write-Ok "Restart PowerShell (or run '. `$PROFILE') to use ccr, ccc, ccp, ccu, ccv, cchere"
}
else {
    Write-Step "Skipping PowerShell profile changes (per -SkipProfile)"
}

# ---------------------------------------------------------------------------
Write-Host ""
Write-Ok "Moon-Terminal installed."
Write-Ok "Restart Windows Terminal, then open the 'Claude Code' profile from the dropdown (or Ctrl+Shift+M)."
