// Modules to control application life and create native browser window
const { app, BrowserWindow, ipcMain } = require('electron');
const request = require('request');

var xmlPath = '';
var spotifyToken = '';

ipcMain.on('switchToMain', (event, arg) => {
  xmlPath = arg;
  mainWindow.loadFile('html/convert.html');
  mainWindow.setBounds({width: 800, height: 600});
});

ipcMain.on('getXmlPath', (event, arg) => {
  event.returnValue = xmlPath;
});

ipcMain.on('getSpotifyToken', (event, arg) => {
  event.returnValue = spotifyToken;
});

let client_id = "3779c98dc12a4cadbe0ccb1167dfb8e9";
let client_secret = "87fae4aa4cb5405fbc305f16af32a95c";

request(
  {
    method: 'POST',
    url: 'https://accounts.spotify.com/api/token',
    form: { grant_type: 'client_credentials' },
    headers : {
      'Authorization': 'Basic ' + Buffer.from(`${client_id}:${client_secret}`).toString('base64'),
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  },
  function (error, response, body) {
    if (error) {
      return console.error('ERROR getting Spotify token: ' + error);
    }
    spotifyToken = JSON.parse(body).access_token;
    console.log(spotifyToken);
  }
);

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 400, height: 250});

  // and load the index.html of the app.
  mainWindow.loadFile('html/upload.html');

  // Open the DevTools.
  mainWindow.webContents.openDevTools();

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  app.quit();
});

app.on('activate', function () {
  if (mainWindow === null) {
    createWindow();
  }
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
