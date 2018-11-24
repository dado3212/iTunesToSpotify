const { ipcRenderer } = require('electron');

$(document).ready(() => {
  let uploader = $('.uploader');
  uploader.on('dragover', () => {
    if (!uploader.hasClass('hovered')) {
      uploader.addClass('hovered');
    }
    return false;
  });
  uploader.on('dragleave dragend', () => {
    if (uploader.hasClass('hovered')) {
      uploader.removeClass('hovered');
    }
    return false;
  });
  uploader.on('drop', (e) => {
    if (uploader.hasClass('hovered')) {
      uploader.removeClass('hovered');
    }

    if (e.originalEvent.dataTransfer && e.originalEvent.dataTransfer.files.length) {
      e.preventDefault();
      e.stopPropagation();

      let files = e.originalEvent.dataTransfer.files;

      var foundOne = false;
      for (var i = 0; i < files.length; i++) {
        if (files[i].type == 'text/xml') {
          foundOne = true;
          // upload files[i].path
          ipcRenderer.send('switchToMain', files[i].path);
          break;
        }
      }

      if (!foundOne) {
        // show a warning
      }
    }

    return false;
  });
});
