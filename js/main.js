const { app, BrowserWindow, ipcMain } = require('electron');
const request = require('request');
const { CLIENT_ID, CLIENT_SECRET } = require('./secret.js');

let xmlPath = '';
let spotifyToken = '';

let mainWindow;

ipcMain.on('switchToMain', (event, arg) => {
  xmlPath = arg;
  mainWindow.loadFile('html/convert.html');
  mainWindow.setResizable(true);
  mainWindow.setSize(1000, 600);
});

ipcMain.on('getXmlPath', (event, arg) => {
  event.returnValue = xmlPath;
});

ipcMain.on('getSpotifyToken', (event, arg) => {
  event.returnValue = spotifyToken;
});

request(
  {
    method: 'POST',
    url: 'https://accounts.spotify.com/api/token',
    form: { grant_type: 'client_credentials' },
    headers : {
      'Authorization': 'Basic ' + Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64'),
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  },
  function (error, response, body) {
    if (error) {
      return console.error('ERROR getting Spotify token: ' + error);
    }
    spotifyToken = JSON.parse(body).access_token;
  }
);

function createWindow () {
  mainWindow = new BrowserWindow({
    width: 500,
    height: 400,
    backgroundColor: '#222222',
    icon: '../icons/png/64x64.png',
  });
  mainWindow.loadFile('html/upload.html');

  // Open the DevTools.
  // mainWindow.webContents.openDevTools();

  mainWindow.setResizable(false);

  mainWindow.on('closed', function () {
    mainWindow = null;
  });
}
app.on('ready', createWindow);

app.on('window-all-closed', function () {
  app.quit();
});

app.on('activate', function () {
  if (mainWindow === null) {
    createWindow();
  }
});
