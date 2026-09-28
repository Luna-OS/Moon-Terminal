# >>> Moon-Terminal: Claude Code helpers >>>
# Managed by Moon-Terminal (https://github.com/luna-os/moon-terminal) - do not edit between these markers,
# re-running install.ps1 will overwrite this block. Remove with uninstall.ps1.

function ccr { claude --resume @args }
function ccc { claude --continue @args }
function ccp { claude --print @args }
function ccv { claude --version }
function ccu { npm update -g @anthropic-ai/claude-code }

function cchere {
    <#
        Opens a new Windows Terminal tab using the Moon-Terminal "Claude Code" profile,
        starting in the current directory.
    #>
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        wt -w 0 nt -p "Claude Code" -d (Get-Location).Path
    }
    else {
        Write-Warning "wt.exe (Windows Terminal) was not found on PATH."
    }
}
# <<< Moon-Terminal: Claude Code helpers <<<
