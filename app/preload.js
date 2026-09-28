const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('moonTerminal', {
  ready: (size) => ipcRenderer.send('pty:ready', size),
  onData: (callback) => ipcRenderer.on('pty:data', (_event, data) => callback(data)),
  onExit: (callback) => ipcRenderer.on('pty:exit', () => callback()),
  input: (data) => ipcRenderer.send('pty:input', data),
  resize: (size) => ipcRenderer.send('pty:resize', size),
  minimize: () => ipcRenderer.send('window:minimize'),
  maximize: () => ipcRenderer.send('window:maximize'),
  close: () => ipcRenderer.send('window:close'),
});
