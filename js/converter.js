var fs = require('fs');
var plist = require('plist');
const { ipcRenderer } = require('electron');
const request = require('request');

var tracks;
var playlists;
var spotifyToken;

$(document).ready(() => {
  handleXML(ipcRenderer.sendSync('getXmlPath'));
  spotifyToken = ipcRenderer.sendSync('getSpotifyToken');
});

function handleXML(xmlPath) {
  console.log(xmlPath);
  fs.readFile(xmlPath, function(err, data){
    let parsed = plist.parse(data.toString());

    tracks = parsed['Tracks'];

    playlists = parsed['Playlists'];

    // Build all of the playlists
    let playlistDiv = $('.playlists');
    playlistDiv.html('');
    for (var i = 0; i < playlists.length; i++) {
      playlistDiv.append(buildPlaylistItem(i));
    }
  });
}

function buildPlaylistItem(i) {
  if (playlists[i].Name && playlists[i]['Playlist Items'] && playlists[i]['Playlist Items'].length) {
    let element = $(`
      <div class="playlist">
        <span class="name">${playlists[i].Name}</span>
        <span class="number">${playlists[i]['Playlist Items'].length.toLocaleString()} songs</span>

      </div>
    `);

    let downloadElement = $('<span class="download"><img src="../images/download.svg"></span>');
    downloadElement.on('click', (e) => {
      e.stopPropagation();
      e.preventDefault();

      handlePlaylistDownload(downloadElement.parent().data('id'));
    });

    element.append(downloadElement);

    element.data('id', i);

    element.on('click', (e) => {
      handlePlaylistClick(element.data('id'));
    });

    return element;
  }
  return null;
}

function handlePlaylistClick(i) {
  let playlistTracks = playlists[i]['Playlist Items'];

  let trackList = $('.tracks');
  trackList.html('');

  for (var j = 0; j < playlistTracks.length; j++) {
    let info = tracks[playlistTracks[j]['Track ID']];
    let trackElement = $(`
      <div class="track">
        <span class="title">${info.Name}</span>
        <span class="artist">${info.Artist}</span>
      </div>
    `);
    trackElement.attr('data-id', info['Track ID']);
    trackList.append(trackElement);
  }
}

function handlePlaylistDownload(i) {
  let playlistTracks = playlists[i]['Playlist Items'];

  let trackList = $('.tracks');

  let handleTrackNumber = (j) => {};
  handleTrackNumber = (trackNum) => {
    if (trackNum < playlistTracks.length) {
      let track = tracks[playlistTracks[trackNum]['Track ID']];

      getSpotifyURI(track, (uri) => {
        if (uri) {
          console.log(uri);
        }
        handleTrackNumber(trackNum + 1);
      });
    }
  }
  handleTrackNumber(0);
}

function getSpotifyURI(track, callback) {
  if (spotifyToken) {
    let requestURL = 'https://api.spotify.com/v1/search?q=';
    requestURL += encodeURIComponent(track.Name);
    if (track.Arist != "") {
      requestURL += "+artist:";
      requestURL += encodeURIComponent(track.Artist);
    }
    requestURL += "&type=track&market=US&limit=1";
    request(
      {
        method: 'GET',
        url: requestURL,
        headers : {
          'Authorization': 'Bearer ' + spotifyToken,
        },
      },
      function (error, response, body) {
        body = JSON.parse(body);
        if (error || !body || !body.tracks || !body.tracks.items || !body.tracks.items.length) {
          $('.track[data-id=' + track['Track ID'] + ']').addClass('failed');
          callback();
          return;
        }
        $('.track[data-id=' + track['Track ID'] + ']').addClass('found');
        track['uri']= body.tracks.items[0].uri;
        callback(body.tracks.items[0].uri);
      }
    );
  } else {
    console.log('Spotify token');
    console.log(spotifyToken);
    $('.track[data-id=' + track['Track ID'] + ']').addClass('failed');
    callback();
  }
}

module.exports = {  };
