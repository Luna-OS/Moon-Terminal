# Moon-Terminal

Eine eigenständige Windows-Terminal-App für [Claude Code](https://claude.com/claude-code) im
dunklen "Moon Dark"-Farbschema. Kein Plugin, kein Profil - eine eigene `.exe`.

## Download

Fertige Windows-Builds (Installer `.exe` + portable `.exe`) werden automatisch von GitHub Actions
erzeugt:

- **Release-Version**: siehe [Releases](../../releases) - entsteht automatisch bei jedem
  Versions-Tag (`vX.Y.Z`).
- **Letzter Entwicklungsstand**: im [Actions](../../actions/workflows/build-windows.yml)-Tab unter
  dem neuesten Lauf auf `main` als Artefakt `moon-terminal-windows`.

Voraussetzung zum Nutzen der App: [Claude Code](https://claude.com/claude-code) ist installiert
und über `claude` auf dem `PATH` erreichbar (`npm i -g @anthropic-ai/claude-code`).

## Was es ist

Eine schlanke [Electron](https://www.electronjs.org/)-App:

- Rahmenlose eigene Titelleiste im Moon-Dark-Look (🌙-Icon, eigene Minimieren/Maximieren/Schließen-Buttons)
- Echtes Terminal via [xterm.js](https://xtermjs.org/) + [node-pty](https://github.com/microsoft/node-pty)
  (ConPTY unter Windows) - startet direkt in PowerShell mit `claude`
- Farbschema "Moon Dark" (Indigo/Silber, mondlicht-goldener Cursor) fest im Terminal verdrahtet

## Selbst bauen

```powershell
cd app
npm install
npm run start   # App direkt starten (Entwicklung)
npm run dist    # Windows-Installer + portable .exe in app\dist\
```

`npm install` ruft automatisch `electron-builder install-app-deps` auf, damit `node-pty`
(natives Modul) gegen die Electron-Node-Version neu gebaut wird - das muss auf Windows laufen,
nicht in WSL/Linux.

## Aufbau

```
app/
  main.js              Electron-Hauptprozess: Fenster, spawnt PowerShell via node-pty
  preload.js            contextBridge zwischen Hauptprozess und Renderer
  renderer/
    index.html          Fenster-Markup + eigene Titelleiste
    style.css            Moon-Dark-Styling
    renderer.js           xterm.js-Setup, Farbschema, Resize-Handling
  build/icon.ico         App-Icon (Mondsichel)
  package.json           Abhängigkeiten + electron-builder-Konfiguration
.github/workflows/
  build-windows.yml      Baut auf windows-latest bei jedem Push/Tag, veröffentlicht Releases
scripts/
  make-icon.py           Erzeugt build/icon.ico neu (benötigt Pillow)
```

## Release erstellen

Ein Tag `vX.Y.Z` auf `main` pushen - der Workflow baut auf einem echten Windows-Runner und lädt
Installer + portable `.exe` automatisch als GitHub Release hoch:

```bash
git tag v0.1.0
git push origin v0.1.0
```

## Lizenz

MIT, siehe [LICENSE](LICENSE).
