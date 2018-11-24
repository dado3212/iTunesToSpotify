var fs = require('fs');
var plist = require('plist');
const { ipcRenderer } = require('electron');

var tracks;
var playlists;

$(document).ready(() => {
  handleXML(ipcRenderer.sendSync('getXmlPath'));
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
      if (playlists[i].Name && playlists[i]['Playlist Items'] && playlists[i]['Playlist Items'].length) {
        let element = $(`
          <div class="playlist">
            <span class="name">${playlists[i].Name}</span>
            <span class="number">${playlists[i]['Playlist Items'].length.toLocaleString()} songs</span>
          </div>
        `);

        element.data('id', i);

        element.on('click', (e) => {
          let playlistTracks = playlists[element.data('id')]['Playlist Items'];

          let trackList = $('.tracks');
          trackList.html('');

          for (var j = 0; j < playlistTracks.length; j++) {
            let info = tracks[playlistTracks[j]['Track ID']]
            let trackElement = $(`
              <div class="track">
                <span class="title">${info.Name}</span>
                <span class="artist">${info.Artist}</span>
              </div>
            `);
            trackElement.data('id', info['Track ID']);
            trackList.append(trackElement);
          }
        });

        playlistDiv.append(element);
      }
    }
  });
  }

module.exports = {  };
