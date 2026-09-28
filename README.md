# Moon-Terminal

Ein dunkles "Moon"-Farbschema und ein eigenes Profil für [Windows Terminal](https://aka.ms/terminal),
zugeschnitten aufs Arbeiten mit [Claude Code](https://claude.com/claude-code) - plus ein paar
Tastenkombinationen und PowerShell-Kurzbefehle für den Alltag. Nur für Windows.

## Was du bekommst

- **Farbschema "Moon Dark"** - ein ruhiges, kontrastreiches Indigo/Silber-Theme.
- **Profil "Claude Code"** - startet direkt mit `claude`, eigenes Icon (🌙), abgestimmt auf das
  Farbschema. Erscheint automatisch im Profil-Dropdown von Windows Terminal.
- **Tastenkombinationen**
  | Tasten | Aktion |
  |---|---|
  | `Strg+Umschalt+M` | Neuer Tab mit dem Claude-Code-Profil |
  | `Strg+Umschalt+K` | Bildschirm + Scrollback komplett leeren |
  | `Strg+Umschalt+Z` | Fokus-Modus umschalten (ausgeblendete Tabs/Ränder) |
- **PowerShell-Kurzbefehle**
  | Befehl | Bedeutung |
  |---|---|
  | `ccr` | `claude --resume` |
  | `ccc` | `claude --continue` |
  | `ccp` | `claude --print` |
  | `ccv` | `claude --version` |
  | `ccu` | Claude Code aktualisieren (`npm update -g @anthropic-ai/claude-code`) |
  | `cchere` | Neuer Windows-Terminal-Tab mit dem Claude-Code-Profil im aktuellen Ordner |

## Voraussetzungen

- Windows 10/11 mit [Windows Terminal](https://aka.ms/terminal) (Version 1.16+ für Fragment-Erweiterungen)
- [Claude Code](https://claude.com/claude-code) installiert und auf dem `PATH` (`npm i -g @anthropic-ai/claude-code`)
- PowerShell 5.1 oder neuer

## Installation

```powershell
git clone https://github.com/luna-os/moon-terminal.git
cd moon-terminal
.\install.ps1
```

Falls PowerShell das Ausführen von Skripten blockiert:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

Das Skript ist so gebaut, dass nichts überschrieben wird, was du nicht erwartest:

- Farbschema + Profil werden als **Fragment-Erweiterung** installiert
  (`%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\Moon-Terminal\`) - deine `settings.json`
  bleibt dafür komplett unangetastet.
- Tastenkombinationen werden **additiv** in `settings.json` eingefügt: vorhandene Belegungen auf
  denselben Tasten werden übersprungen, und vor jeder Änderung wird ein Backup
  (`settings.json.bak-<Zeitstempel>`) angelegt.
- Die PowerShell-Kurzbefehle landen in deinem `$PROFILE`, klar markiert zwischen
  `# >>> Moon-Terminal ... >>>` und `# <<< Moon-Terminal ... <<<`, damit erneutes Ausführen von
  `install.ps1` sauber bleibt.

Optionen:

```powershell
.\install.ps1 -SkipKeybindings   # settings.json nicht anfassen
.\install.ps1 -SkipProfile       # $PROFILE nicht anfassen
```

Danach: Windows Terminal neu starten und das Profil **"Claude Code"** über das Dropdown
(oder `Strg+Umschalt+M`) öffnen.

## Deinstallation

```powershell
.\uninstall.ps1
```

Entfernt die Fragment-Dateien, die von Moon-Terminal hinzugefügten Tastenkombinationen (mit Backup)
und den markierten Block in deinem `$PROFILE`.

## Manuelle Installation

Falls du das Skript nicht nutzen willst:

1. Kopiere [`windows-terminal/fragment/moon-terminal.json`](windows-terminal/fragment/moon-terminal.json)
   nach `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\Moon-Terminal\moon-terminal.json`
   (Ordner ggf. anlegen).
   *Oder*: Öffne Windows Terminal → Einstellungen → JSON-Datei öffnen und füge den Inhalt von
   `profiles` und `schemes` manuell in deine eigene `settings.json` ein.
2. Übernimm bei Bedarf die Einträge aus [`windows-terminal/keybindings.json`](windows-terminal/keybindings.json)
   in den `keybindings`-Abschnitt deiner `settings.json`.
3. Füge den Inhalt von [`powershell/Claude-Code.profile.ps1`](powershell/Claude-Code.profile.ps1)
   an dein PowerShell-Profil (`$PROFILE`) an.

## Farbpalette

| Rolle | Hex |
|---|---|
| Hintergrund | `#10121C` |
| Vordergrund | `#D8DEE9` |
| Cursor / Akzent | `#E0C880` |
| Auswahl | `#364A82` |
| Blau | `#7AA2F7` |
| Lila | `#BB9AF7` |
| Cyan | `#7DCFFF` |
| Grün | `#9ECE6A` |
| Rot | `#F7768E` |

## Lizenz

MIT, siehe [LICENSE](LICENSE).
