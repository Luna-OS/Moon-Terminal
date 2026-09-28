const { app, BrowserWindow, ipcMain, Menu } = require('electron');
const path = require('path');
const os = require('os');
const pty = require('node-pty');

const MOON_BACKGROUND = '#10121C';

/** @type {BrowserWindow | null} */
let mainWindow = null;
/** @type {import('node-pty').IPty | null} */
let ptyProcess = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1000,
    height: 640,
    minWidth: 480,
    minHeight: 300,
    backgroundColor: MOON_BACKGROUND,
    frame: false,
    icon: path.join(__dirname, 'build', 'icon.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
    },
  });

  Menu.setApplicationMenu(null);
  mainWindow.loadFile(path.join(__dirname, 'renderer', 'index.html'));

  mainWindow.on('closed', () => {
    mainWindow = null;
    if (ptyProcess) {
      ptyProcess.kill();
      ptyProcess = null;
    }
  });
}

function spawnShell(cols, rows) {
  if (ptyProcess) return;

  ptyProcess = pty.spawn('powershell.exe', ['-NoLogo', '-NoExit', '-Command', 'claude'], {
    name: 'xterm-256color',
    cols: cols || 80,
    rows: rows || 30,
    cwd: os.homedir(),
    env: process.env,
  });

  ptyProcess.onData((data) => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('pty:data', data);
    }
  });

  ptyProcess.onExit(() => {
    ptyProcess = null;
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('pty:exit');
    }
  });
}

ipcMain.on('pty:ready', (_event, size) => {
  spawnShell(size && size.cols, size && size.rows);
});

ipcMain.on('pty:input', (_event, data) => {
  if (ptyProcess) ptyProcess.write(data);
});

ipcMain.on('pty:resize', (_event, { cols, rows }) => {
  if (ptyProcess && cols > 0 && rows > 0) {
    try {
      ptyProcess.resize(cols, rows);
    } catch {
      // The pty may already have exited; ignore.
    }
  }
});

ipcMain.on('window:minimize', () => mainWindow && mainWindow.minimize());
ipcMain.on('window:maximize', () => {
  if (!mainWindow) return;
  if (mainWindow.isMaximized()) mainWindow.unmaximize();
  else mainWindow.maximize();
});
ipcMain.on('window:close', () => mainWindow && mainWindow.close());

app.whenReady().then(() => {
  if (process.platform !== 'win32') {
    // eslint-disable-next-line no-console
    console.warn('Moon Terminal targets Windows (PowerShell). Continuing anyway for development.');
  }
  createWindow();
});

app.on('window-all-closed', () => {
  app.quit();
});
