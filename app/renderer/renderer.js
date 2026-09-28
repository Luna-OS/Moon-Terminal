const term = new Terminal({
  fontFamily: "'Cascadia Code', Consolas, monospace",
  fontSize: 14,
  cursorBlink: true,
  scrollback: 5000,
  theme: {
    background: '#10121C',
    foreground: '#D8DEE9',
    cursor: '#E0C880',
    cursorAccent: '#10121C',
    selectionBackground: '#364A82',
    black: '#1A1B26',
    red: '#F7768E',
    green: '#9ECE6A',
    yellow: '#E0C880',
    blue: '#7AA2F7',
    magenta: '#BB9AF7',
    cyan: '#7DCFFF',
    white: '#C0CAF5',
    brightBlack: '#414868',
    brightRed: '#FF8095',
    brightGreen: '#B9F27C',
    brightYellow: '#F0D99B',
    brightBlue: '#8FB8FF',
    brightMagenta: '#D1B8FF',
    brightCyan: '#A3E8FF',
    brightWhite: '#E8ECFB',
  },
});

const fitAddon = new FitAddon.FitAddon();
term.loadAddon(fitAddon);
term.open(document.getElementById('terminal'));
fitAddon.fit();
term.focus();

function sendSize() {
  window.moonTerminal.resize({ cols: term.cols, rows: term.rows });
}

window.addEventListener('resize', () => {
  fitAddon.fit();
  sendSize();
});

window.moonTerminal.onData((data) => term.write(data));
window.moonTerminal.onExit(() => {
  term.write('\r\n\x1b[90m[Prozess beendet]\x1b[0m\r\n');
});

term.onData((data) => window.moonTerminal.input(data));

window.moonTerminal.ready({ cols: term.cols, rows: term.rows });

document.getElementById('btn-min').addEventListener('click', () => window.moonTerminal.minimize());
document.getElementById('btn-max').addEventListener('click', () => window.moonTerminal.maximize());
document.getElementById('btn-close').addEventListener('click', () => window.moonTerminal.close());
